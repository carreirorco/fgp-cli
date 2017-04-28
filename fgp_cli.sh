#! /bin/bash

#################################################################################
# Obter dados do usuario
#################################################################################

rm=$(dialog --inputbox --stdout "Informe o RM" 0 0 )
senha=$(dialog --passwordbox --stdout "Informe a Senha" 0 0 )

#################################################################################
# Declarar variaveis
#################################################################################

path_tmp=".cache"
arquivo="${path_tmp}/new_html.html"
arquivo_notas="${path_tmp}/notas_html"
file_cookie="${path_tmp}/newcookies.txt"

_frequencias="${path_tmp}/_frequencias_1bim.txt"
_disciplinas="${path_tmp}/_disciplinas_1bim.txt"
_notas_1bim="${path_tmp}/_notas_1bim.txt"
__disciplinas="${path_tmp}/__disciplinas.txt"

frequencias="${path_tmp}/frequencias_1bim.txt"
disciplinas="${path_tmp}/disciplinas_1bim.txt"
notas_1bim="${path_tmp}/notas_1bim.txt"
resultado_final="${path_tmp}/resultado_final.txt"

#################################################################################
# Faz login e obtem dados
#################################################################################

mkdir ${path_tmp} 2> /dev/null

curl -s -d "rm=${rm}&senha=${senha}&login=entrar" --output ${arquivo} \
-X POST "http://fgp.com.br/novoAluno2012/loginasp.asp" \
--cookie-jar ${file_cookie}

curl -s 'http://fgp.com.br/novoAluno2012/loginasp.asp' \
-H 'Cookie: ASPSESSIONIDASTADSCS=AGGDBPNDENOFHEMELCMPHKKO; ASPSESSIONIDASQDBTDT=IHHOKLKAINNAEEJLPFNLLFBJ' \
-H 'Origin: http://fgp.com.br' \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4' \
-H 'Upgrade-Insecure-Requests: 1' \
-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
-H 'Cache-Control: max-age=0' \
-H 'Referer: http://fgp.com.br/novoAluno2012/default2.asp' \
-H 'Connection: keep-alive' \
-H 'DNT: 1' \
--data "rm=${rm}&senha=${senha}" \
--compressed \
--output ${arquivo}

curl -s "http://fgp.com.br/novoAluno2012/default2.asp?Pagina=Notas/Frequencia&l_str_rm=${rm}" \
-H 'DNT: 1' \
-H 'Accept-Encoding: gzip, deflate, sdch' \
-H 'Accept-Language: pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4' \
-H 'Upgrade-Insecure-Requests: 1' \
-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
-H 'Referer: http://fgp.com.br/novoAluno2012/default2.asp?Pagina=Aluno_Inicial' \
-H 'Cookie: ASPSESSIONIDASTADSCS=AGGDBPNDENOFHEMELCMPHKKO; ASPSESSIONIDASQDBTDT=IHHOKLKAINNAEEJLPFNLLFBJ' \
-H 'Connection: keep-alive' \
--compressed \
--output ${arquivo_notas}

################################################################################
# Pegar Disciplinas primeiro bimestre
################################################################################

grep '<!--disciplina -->' ${arquivo_notas} | cut -d';' -f2 | sed 's/<.*//g' > ${_disciplinas}
cat ${_disciplinas} | sed 's/[\ \t]*$//g' > ${disciplinas}

################################################################################
# Pegar Frequencias primeiro bimestre
################################################################################

grep -A1 '<!--Frequencia 1Bim -->' ${arquivo_notas} | awk -F'\t' '{print $7}' | grep -v ^\< | grep [0-9] > ${_frequencias}
cat ${_frequencias} | sed 's/[\ \t]*$//g' > ${frequencias} 

################################################################################
# Pegar Notas primeiro bimestre
################################################################################

grep  '<!--Nota 1Bim -->' ${arquivo_notas} | awk -F'>' '{print $3}' | sed 's/<.*//g' > ${_notas_1bim}
cat ${_notas_1bim} | sed 's/[\ \t]*$//g' > ${notas_1bim}

################################################################################
# Formatar a saida
################################################################################

cat $disciplinas | \
sed 's/R. C./Redes de Computadores    /g'        | \
sed 's/fil./Filosofia                /g'         | \
sed 's/P.II/Programacao II           /g'         | \
sed 's/E.D./Estrutura de Dados II    /g'         | \
sed 's/S.I/Sistemas de Informacao   /'           | \
sed 's/Eng. Sof. II/Engenharia de Software II/g' | \
sed 's/BD II/Banco de Dados II        /g'        | \
sed 's/probabilidade/Probabilidade            /' > ${__disciplinas}

paste ${__disciplinas} $notas_1bim $frequencias > ${resultado_final}
dialog --textbox  "${resultado_final}" 12 47
