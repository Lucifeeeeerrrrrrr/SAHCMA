# `get_temp`

```bash
get_temp() {  
    local temp_raw  
    temp_raw=$(sensors 2>/dev/null | grep -m1 'Package id 0' | awk '{print $4}' | tr -d '+°C' 2>/dev/null)  
    echo "${temp_raw:-40}"  
}
```
Consulta direta de sensores térmicos via `lm-sensors`.
* Finalidade: mapear **tensão térmica do subsistema de processamento**.
* Por padrão, fallback retorna 40°C — aproximação de baseline térmico nominal.

## Como Funciona

A decisão de retornar um fallback de 40 graus se não houver. A leitura é pragmática, mas também simbólica: mesmo sem feedback do sensor, a máquina simula temperatura pra garantir que não quebre o programa.
> Se a PORRA do `lm-sensor` não estiver instalada, o script chuta a temperatura pra 40°C e segue como se nada tivesse acontecido. É o equivalente a dirigir bêbado com fé em Deus, cofesso, mas foi só uma tentativa kkkkk.

## Relação com Redes Neurais

É outro input do mundo físico (estado térmico). Serve como canal paralelo de entrada contextual, igual a como algumas redes processam modalidades múltiplas (tipo som + imagem, ou CPU + temp).

Isso cria um vetor de entrada multicanal, o que é um pré-requisito pra qualquer rede que deseja adaptar comportamento com base em contexto externo e interno.
> Isso aproxima o sistema de uma rede multiinput, o que já nos tira da caverna do simples feedback loop reativo.