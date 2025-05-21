# `apply_tdp_profile`

Esse função **aplica limites de potência (TDP)** na CPU Intel de 8 geração(sou um pobre fodido ao extremo, semi-morador de rua e sobrevivo com 3 reais por dia, então é um milagre que não esteja codando em um abaco) **em tempo real**, de forma **granular**, calculando os valores de `power_limit_uw` baseados num mapa de perfis e respeitando cooldowns térmicos e mecânicos de forma automatizada sem intervenção humana.
```bash
apply_tdp_profile() {
    local key="$1"
    declare -A MAP
    MAP["000"]="0 0"
    MAP["005"]="$((MAX_TDP * 15 / 100)) $((MAX_TDP * 0))"
    MAP["020"]="$((MAX_TDP * 30 / 100)) $((MAX_TDP * 10 / 100))"
    MAP["040"]="$((MAX_TDP * 45 / 100)) $((MAX_TDP * 20 / 100))"
    MAP["060"]="$((MAX_TDP * 60 / 100)) $((MAX_TDP * 30 / 100))"
    MAP["080"]="$((MAX_TDP * 75 / 100)) $((MAX_TDP * 40 / 100))"
    MAP["100"]="$((MAX_TDP)) $((MAX_TDP * 50 / 100))"
    local tdp_pair="${MAP[$key]}"
    [[ -z "$tdp_pair" ]] && { echo "❌ Perfil TDP inválido"; return 1; }
    read target_max target_min <<< "$tdp_pair"
    
    local now=$(date +%s)
    local current_power="${target_min} ${target_max}"
    local last_power_file="${BASE_DIR}/last_power"
    local cooldown_file="${BASE_DIR}/power_cooldown"
    local last_power="none"
    [[ -f "$last_power_file" ]] && last_power=$(cat "$last_power_file")
    local last_change=0
    [[ -f "$cooldown_file" ]] && last_change=$(date -r "$cooldown_file" +%s)
    local delta=$((now - last_change))
    local dynamic_cd=$(calc_dynamic_cooldown)
    echo "🌡  Temp=$(get_temp)°C | ΔCarga=$(get_load_variance) | Cooldown=${dynamic_cd}s"
    if [[ "$current_power" != "$last_power" ]]; then
        if (( delta >= dynamic_cd )); then
            echo "⚡ Aplicando TDP: MIN=${target_min}W | MAX=${target_max}W"
            echo $((target_min * 1000000)) > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw 2>/dev/null
            echo $((target_max * 1000000)) > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null
            echo "$current_power" > "$last_power_file"
            touch "$cooldown_file"
        else
            echo "⏳ Cooldown ativo: ${delta}s/${dynamic_cd}s"
        fi
    else
        echo "✅ TDP já aplicado (MIN=${target_min}, MAX=${target_max})"
    fi
}

```
---

## Poque essa ideia?

CPUs modernas permitem **modular o TDP via RAPL**, mas a maioria dos sistemas trata isso como:
> “Seta uma vez na BIOS e reza.”

Porém na maior parte do tempo, o usuário médio não precisa de um valor fixo, onde através de uma lógica bizarra (primeiro chega a temperatura crítica para depois fazer algo), aqui a pegada é **runtime control via script**, com:

* Perfil numérico adaptável (`000` a `100`)
* **Persistência de última config** (pra não reescrever como um jegue)
* **Cooldown dinâmico** baseado no sistema
* Logging com temperatura e carga

Ou seja: **controle homeostático inteligente**, onde, o computador tenta se autoajusta, transitando de unclock para aumentar sua vida util até overclock caso você esteja tentando rodar crysis.

---

## Como ele funciona?

A `KEY` é um código tipo `"000"`, `"060"`, `"100"`... Cada um mapeia pra um par `MAX_TDP` e `MIN_TDP`, calculado **proporcionalmente ao TDP máximo da CPU**.

Exemplo da tabela de mapeamento:

```bash
["000"]="0 0"                          # Sim, da para usar no 0% 90% do tempo, e isso é empirico
["005"]="15% do max / 0% do min"      # Ultra low-power
["020"]="30% max / 10% min"
["040"]="45% max / 20% min"
["060"]="60% max / 30% min"
["080"]="75% max / 40% min"
["100"]="100% max / 50% min"          # Overclock
```

---

## 🔁 Fluxo operacional

1. Converte o `KEY` para par `(max, min)`
2. Compara com o último valor usado (`last_power`)
3. Checa o tempo de cooldown (`power_cooldown`)
4. Se mudou **e** passou o tempo:
   * Aplica `min` e `max` via sysfs
   * Atualiza `last_power`
   * Reinicia cooldown com `touch`
5. Se não mudou → ignora
6. Se cooldown ainda ativo → aguarda

---

## Detalhes técnicos

### Arquivos de estado

```bash
$BASE_DIR/last_power       # String tipo "30 15"
$BASE_DIR/power_cooldown   # Timestamp do último apply
```

Servem pra evitar:

* Reaplicações idiotas (desgaste)
* Corrida de processos (se integrado com monitoramento paralelo)
* Reações desnecessárias a spikes temporários

---

### Aplicação dos limites

```bash
/sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw   ← MAX
/sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw   ← MIN
```
> ADAPTADO PARA O MEU SISTEMA A FIM DE TESTES, IMPLEMENTACAO DEVE SER MAIS ESTUDADA
> **Obs:** valores em microssegundos de watt (`µW`), então basta multiplicar por `1_000_000`.
> Se falhar → redireciona erro e segue.

---

### Cooldown dinâmico?

Aqui, através de uma função externa controlo a execução, dado que mudanças bruscas sem inteligencia pode quebrar o sistema, causar throlling ou travar, e embora eu ainda esteja meio quebrado no tempo, é necessario testar e otimizar o tempo, então sinta-se livre para otimizar esse script

* Ajustar cooldown conforme:
  * Temperatura (`get_temp`)
  * Variação de carga (`get_load_variance`)
  * Algum modelo esperto ou fórmula fuleira

> Se quiser, pode usar PID controller ou modelo fuzzy. O hook já tá pronto.

---

## 🔐 Mecanismos de segurança

1. **Persistência de estado**
   Não reaplica TDP igual. Não queima ciclo à toa.

2. **Cooldown inteligente**
   Não troca de perfil feito doido. Toma tempo proporcional à treta.

3. **Fallback sem pânico**
   Se o `KEY` é inválido → printa erro e aborta.

4. **Debug verboso discreto**
   Print formatado: temperatura, delta de carga e cooldown atual.

---

## 💣 Quando meter `KEY=100`?

Quando você quer **expreme ao máximo o sistema**, mas com controle:

* Jogos
* Render pesado
* Benchmark curto
* Stress test com throttling manual
* Quando você esta acordado meia noite usando sitess de "teste"

---

## 🧊 Quando usar `KEY=000`?

* Script de hibernação
* Limitação de energia por bateria
* CPU esquentando como um fogão
* Dormência voluntária
> Sim, isso forçou meu notebook a 0, e mesmo esquecendo ele ligado, quando vi o log, fiquei impressionado que ele não estava quente como antes acontecia.
---

## 🤘 Por que é útil?

Pois sem a interverção humana, o sistema se autoajusta e usa apenas o necessário seguindo uma homeostase, onde ao invés de esperar dar treco, ele se autoajusta e assim podendo, em teoria, economizar energia ao não resfriar o ambiente(1w de processamento = 3w de resfriamento).

Além do mais, dado a facilidade de configuração dele, (sim, é bem simples quando se tem um certo conhecimento), ele pode ser portado e universalizado de forma prática e sem difilcudades.