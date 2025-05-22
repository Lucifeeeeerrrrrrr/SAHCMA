## 🔄 `calc_dynamic_cooldown`- Modulação Escalonada por Severidade

```bash
calc_impact_cooldown() {
    local base_cd=$(calc_dynamic_cooldown)
    local impact_factor="$1"
    echo $(awk -v cd="$base_cd" -v factor="$impact_factor" 'BEGIN {print int(cd * factor)}')
}
```
Essa é uma **multiplicação da latência base pelo fator de impacto da ação proposta**.
* Ações mais agressivas → cooldown mais longo;
* Ações triviais → quase imediato.

Serve como **mecanismo de mitigação de efeitos colaterais**.

Esse comportamento é o embrião de uma forma de **autorregulação homeostática computacional**. O que, filosoficamente falando, é o caralho do **deslocamento da reatividade para a intencionalidade**, onde o sistema apresenta uma especie de escolha rudimentar.