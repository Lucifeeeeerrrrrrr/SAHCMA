# Ganhos em relação entre o método tradicional e o meu

| **Característica**    | **Método Tradicional (Ex: Kernel Default, TLP Simples)**                                | **Meu Método (Holístico Adaptativo)**                                                               |
| --------------------- | --------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| **Tomada de Decisão** | Geralmente reativa, baseada em 1 ou 2 fatores (uso CPU instantâneo, AC/Bateria).        | Proativa e holística, baseada em múltiplos fatores combinados (tendência de uso CPU, temp, AC/Bat). |
| **Configuração**      | Aplica políticas genéricas (powersave, performance) ou ajustes isolados por ferramenta. | Aplica um conjunto _completo_ e _integrado_ de configurações (CPU, GPU, ZRAM, Swappiness, EPB).     |
| **Complexidade**      | Baixa complexidade intrínseca, mas pode exigir múltiplas ferramentas e configs.         | Média complexidade no script, mas centraliza o controle e simplifica a gestão geral.                |
| **Adaptação**         | Geralmente mais lenta ou baseada em limiares simples, pode oscilar muito.               | Rápida seleção de estados pré-definidos e estáveis, com suavização de entrada (EMA).                |
| **Granularidade**     | Menos granular, com poucos estados (AC vs Bateria, talvez ondemand vs powersave).       | Alta granularidade através das chaves combinadas, permitindo estados intermediários finos.          |
| **Filosofia**         | Reagir ao uso atual, focar em extremos (máxima economia ou máximo desempenho).          | Antecipar a necessidade baseado na tendência, otimizar para o _cenário_ atual, buscando eficiência. |
| **Estabilidade**      | Pode causar mais flutuações (ex: ondemand subindo e descendo rápido).                   | Busca estados mais estáveis, a mudança é uma transição para um novo platô otimizado.                |
