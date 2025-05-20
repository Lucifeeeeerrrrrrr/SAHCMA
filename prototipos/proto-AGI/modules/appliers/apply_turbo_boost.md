# apply_turbo_boost

+ A configuarcao no meu SO por algum motivo veio com o turbo boost ativado por default, onde, mesmo ocioso, era totalmente desnecessario
+ Decidi cruzar essa configuracao com o governor performance, e entao ativar para o sistema
+ Ele funciona atraves de um logica booleana (1 ou 0), onde atraves de uma condicional simples, posso traves de um unico echo ativar ou desativar o atributo sem ter que flodar a tabela de cruzamento com outra coluna de valores repetidos, reduzindo a complexidade final
+ Foi implementada dupla validacao

---

```bash
apply_turbo_boost() {
    local gov="$1"
    local boost_path="/sys/device/system/cpu/cpufreq/boost"
    local boost_file="${BASE_DIR}/last_turbo"
    local last="none"
    [[ -f "$boost_file" ]] && last=$(cat "$boost_file")

    if [[ -f "$boost_path" ]]; then
        if [[ "$gov" == "performance" && "$last" != "1" ]]; then
            echo 1 > "$boost_path"
            echo "1" > "$boost_file"
            echo " Turbo Boost Ativado "
        elif [[ "$gov" != "performance" && "$last" != "0" ]]; then
            echo 0 > "$boost_path"
            echo "0" > "$boost_file"
            echo " Turbo Boost desativado"
        fi
    fi
}
```
