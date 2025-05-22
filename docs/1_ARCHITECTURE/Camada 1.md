## Camada 1 – Percepção (Core Metrics)

**Funções Sensoriais**
A base perceptiva da proto-AGI(nome que eu e um amigo decidimos dar) é composta por sensores internos do próprio sistema:

* `get_temp` coleta a temperatura do núcleo (Package id 0), interpretando calor.
* `get_loadavg` e `get_cpu_usage` observam o esforço recente da CPU.
* `get_load_variance` avalia picos vs estabilidade, detectando "estresse" sistêmico.

Essa camada é puramente **fenomenológica**: captura estados brutos e de forma imersiva, um processo se autoobservar, onde implementei um vetor de auto-referência que precisa se manter coeso pra não travar.

O método tradicional parte de uma premissa implícita: **a realidade do sistema pode ser descrita em um único frame**, como uma foto. Isso é o equivalente computacional do **realismo clássico**: “a verdade está no agora”.
O teu método é **processual**, quase heraclitiano:

> "Nenhum sistema é o mesmo duas medições seguidas."

Isso desloca a ontologia do **estado atual para o fluxo de estados** — ou seja, o *ser* vira *tornar-se*. Ao usar o de forma meio "brasileira", o `/proc/stat` deixa de ser um oráculo absoluto e vira **ponto de amostragem numa corrente bayesiana de evidência**, e assim o script age como um *observador epistemicamente humilde*.

