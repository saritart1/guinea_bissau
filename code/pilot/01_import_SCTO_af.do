
/*******************************************************************************
  Project:   Guinea Bissau - Chilcare and motherhood

  Title:          01_import_SCTO_af
  Author:         Sara Restrepo Tamayo
  Date:           May 2025
  Version:        Stata 18
  Resume:         SCTO labelling document
  
*******************************************************************************/

************************************************
**#                 0. Key Macros              *
************************************************

*Folder globals

di "current user: `c(username)'"

if "`c(username)'" == "sararestrepotamayo"{
	global github_dofiles "/Users/sararestrepotamayo/Documents/GitHub/guinea_bissau/guinea_bissau/code"
}

do "$github_dofiles/00_paths.do" 


* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "$raw_data/Agregados Familiares_WIDE.csv"
local dtafile "$intermediate_data/Agregados Familiares.dta"
local corrfile "$intermediate_data/Agregados Familiares_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum caseid sstrm_pct_conversation today durinsecs durinmins durinhrs cal_version enumerator enumerator_id enum_name ini_mod_0 setor_oth tabanca name_crianca"
local text_fields2 "cod_jardim name_jardim treatment fin_mod_0 duracao_mod_0 inicio_mod_1 eligi03_oth eligi05_13 eligi05_14 name_respondent roster_criancas_count index_eligi10_* eligi10_* eligi14 eligi14_1 eligi16_1"
local text_fields3 "fin_mod_1 duracao_mod_1 ini_cons cons04 cons05_1 phone01 phone02 fin_cons duracao_cons inicio_af fam04_1 fam06_1 fam07_1 fam08_1 fam09_1 fam10_1 fam11 fam14_1_oth fam15 fam15_1 fim_af duracao_af"
local text_fields4 "inicio_mebros_af total_ag_fam agre_fam03 agre_fam07 agre_fam15 roster_membros_count posicion_miembro_* agre_fam11_* agre_fam19 agre_fam23 fim_membros_af duracao_mebros_af inicio_mae mae09_1 fim_mae"
local text_fields5 "duracao_mae inicio_emprego emprego03_oth emprego04_oth emprego06_oth emprego07_oth emprego08 emprego11_oth emprego13 emprego17_oth emprego18 fim_emprego duracao_emprego inicio_tempo tempo03"
local text_fields6 "hora_loop_count hora_ini_* hora_fin_* tempo04_oth_* temporary_fora_casa temporary_domesticas temporary_cuidado temporary_descanso tempo06 tempo06_oth tempo07 tempo07_oth tempo08 tempo08_oth tempo09"
local text_fields7 "tempo09_oth fim_tempo duracao_tempo inicio_decisao decisao06_oth decisao07_oth decisao08_oth decisao09_oth decisao10_oth fim_decisao duracao_decisao inicio_estres random01 fim_estres duracao_estres"
local text_fields8 "inicio_ansiedad fim_ansiedad duracao_ansiedad inicio_crianca tempor_edad crianca_idade crianca_idade_meses cuidador_h_count index_cuidador_* temporary_hora_cuidado_* temporary_hora_cuidado2_*"
local text_fields9 "crianca09_* fim_crianca duracao_crianca inicio_cuidador cuidador02_13 cuidador02_14 cuidador08_oth cuidador15 cuidador15_outra fim_cuidador duracao_cuidador inicio_servicios servicios01"
local text_fields10 "servicios01_oth servicios07 servicios08 servicios08_oth servicios13 servicios13_oth servicios14 servicios14_oth servicios16 servicios17 servicios17_oth servicios19 servicios19_oth fim_servicios"
local text_fields11 "duracao_servicios inicio_horario horario03 horario04 horario05 horario09 horario09_oth fim_horario duracao_horario inicio_ambiente ambiente10 ambiente11 ambiente12 ambiente13 ambiente14 ambiente15"
local text_fields12 "fim_ambiente duracao_ambiente inicio_disciplina fim_disciplina duracao_disciplina inicio_saude saude06 saude10 saude12 saude15 saude15_oth saude17 saude17_oth saude19 saude19_oth saude21 saude21_oth"
local text_fields13 "saude23 saude23_oth fim_saude duracao_saude inicio_desenvolvimiento_1 fim_desenvolvimiento_1 duracao_desenvolvimiento_1 inicio_desenvolvimiento_2 fim_desenvolvimiento_2 duracao_desenvolvimiento_2"
local text_fields14 "inicio_desenvolvimiento_3 fim_desenvolvimiento_3 duracao_desenvolvimiento_3 comments fim_encuesta duracao_encuesta instanceid"
local date_fields1 "date crianca01"
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable enumerator "Selecione seu nome"
	note enumerator: "Selecione seu nome"

	label variable date "Digite a data de hoje"
	note date: "Digite a data de hoje"

	label variable regiao "0.3 Região"
	note regiao: "0.3 Região"
	label define regiao 1 "Tombali" 2 "Quinara" 3 "Oio" 4 "Biombo" 5 "Bafata" 6 "Gabu" 7 "Cacheu" 8 "SAB"
	label values regiao regiao

	label variable sector "0.4 Sector"
	note sector: "0.4 Sector"
	label define sector 1 "Prabis" 2 "Quinhamel" 3 "Safim" -777 "Outro" 4 "Buba" 5 "Empada" 6 "Fulacunda" 7 "Tite"
	label values sector sector

	label variable setor_oth "0.4 Setor: OUTRO"
	note setor_oth: "0.4 Setor: OUTRO"

	label variable tabanca "0.5 Tabanca."
	note tabanca: "0.5 Tabanca."

	label variable gpslatitude "Coordenada GPS (latitude)"
	note gpslatitude: "Coordenada GPS (latitude)"

	label variable gpslongitude "Coordenada GPS (longitude)"
	note gpslongitude: "Coordenada GPS (longitude)"

	label variable gpsaltitude "Coordenada GPS (altitude)"
	note gpsaltitude: "Coordenada GPS (altitude)"

	label variable gpsaccuracy "Coordenada GPS (accuracy)"
	note gpsaccuracy: "Coordenada GPS (accuracy)"

	label variable name_crianca "0.5 \${enum_name} Por favor escreva o nome e o apelido da criança"
	note name_crianca: "0.5 \${enum_name} Por favor escreva o nome e o apelido da criança"

	label variable cod_jardim "1.2 Que jardim es?"
	note cod_jardim: "1.2 Que jardim es?"

	label variable eligi01 "1.1 A senhora é a mãe biológica de \${name_crianca}?"
	note eligi01: "1.1 A senhora é a mãe biológica de \${name_crianca}?"
	label define eligi01 1 "Sim" 0 "Não"
	label values eligi01 eligi01

	label variable eligi02 "Posso falar, por favor, com a mãe biológica?"
	note eligi02: "Posso falar, por favor, com a mãe biológica?"
	label define eligi02 1 "Sim" 0 "Não"
	label values eligi02 eligi02

	label variable eligi03 "1.2 A mãe biológica mora com \${name_crianca}?"
	note eligi03: "1.2 A mãe biológica mora com \${name_crianca}?"
	label define eligi03 1 "Sim mas não pode responder por outros motivos" 0 "Não"
	label values eligi03 eligi03

	label variable eligi03_oth "1.2.1 Especifique outro motivo"
	note eligi03_oth: "1.2.1 Especifique outro motivo"

	label variable eligi05 "1.5 Quem é a principal cuidadora mulher de \${name_crianca}?"
	note eligi05: "1.5 Quem é a principal cuidadora mulher de \${name_crianca}?"
	label define eligi05 3 "Irmã" 4 "Prima" 7 "Tia" 9 "Avó" 11 "Madrasta" 13 "Outro familiar" 14 "Outro não parente"
	label values eligi05 eligi05

	label variable eligi05_13 "1.5.1 Quem é a principal cuidadora mulher de \${name_crianca}? OUTRO FAMILIAR"
	note eligi05_13: "1.5.1 Quem é a principal cuidadora mulher de \${name_crianca}? OUTRO FAMILIAR"

	label variable eligi05_14 "1.5.1 Quem é a principal cuidadora mulher de \${name_crianca}? OUTRO NÃO PARENTE"
	note eligi05_14: "1.5.1 Quem é a principal cuidadora mulher de \${name_crianca}? OUTRO NÃO PARENTE"

	label variable name_respondent "1.5.2 Qual é o nome completo da senhora?"
	note name_respondent: "1.5.2 Qual é o nome completo da senhora?"

	label variable eligi06 "1.6 A senhora tem:"
	note eligi06: "1.6 A senhora tem:"
	label define eligi06 1 "Menos de 15 anos [Não entreviste essa pessoa, explique a razão e termine a entre" 2 "15-17 anos" 3 "18 anos ou mais"
	label values eligi06 eligi06

	label variable menor_15_check "Não podemos entrevistar pessoas menores de 15 anos. Você poderia, por favor, enc"
	note menor_15_check: "Não podemos entrevistar pessoas menores de 15 anos. Você poderia, por favor, encontrar uma mulher para cuidar de \${name_crianca}, que tem mais de 14 anos?"
	label define menor_15_check 1 "Sim" 0 "Não"
	label values menor_15_check menor_15_check

	label variable eligi07 "1.7 \${name_crianca} está inscrita no jardim de infância \${name_jardim}?"
	note eligi07: "1.7 \${name_crianca} está inscrita no jardim de infância \${name_jardim}?"
	label define eligi07 1 "Sim" 0 "Não [Não entreviste essa pessoa, explique a razão e termine a entrevista.]"
	label values eligi07 eligi07

	label variable eligi08 "1.8 Há alguma outra criança no seu agregado familiar que a senhora cuida e que e"
	note eligi08: "1.8 Há alguma outra criança no seu agregado familiar que a senhora cuida e que está inscrita no jardim \${name_jardim}?"
	label define eligi08 1 "Sim" 0 "Não"
	label values eligi08 eligi08

	label variable eligi09 "1.9 Quantas crianças fazem parte do agregado familiar da senhora e que estão ins"
	note eligi09: "1.9 Quantas crianças fazem parte do agregado familiar da senhora e que estão inscritas no jardim \${name_jardim}?"

	label variable eligi11 "1.11 A senhora vai ficar até o final da campanha de cajú de 2025 (julho) nesta t"
	note eligi11: "1.11 A senhora vai ficar até o final da campanha de cajú de 2025 (julho) nesta tabanca?"
	label define eligi11 1 "Sim" 0 "Não [Não entreviste essa pessoa, explique a razão e termine a entrevista.]"
	label values eligi11 eligi11

	label variable eligi12 "1.12 [NÃO LEIA] O(a) inquirido(a) pertence ao agregado familiar indicado pelo su"
	note eligi12: "1.12 [NÃO LEIA] O(a) inquirido(a) pertence ao agregado familiar indicado pelo supervisor?"
	label define eligi12 1 "Sim" 0 "Não [Não entreviste essa pessoa, explique a razão e termine a entrevista.]"
	label values eligi12 eligi12

	label variable eligi14 "1.14 Quais são as línguas da respondente?"
	note eligi14: "1.14 Quais são as línguas da respondente?"

	label variable eligi14_1 "1.14.1 Especifique outra lingua"
	note eligi14_1: "1.14.1 Especifique outra lingua"

	label variable eligi15 "1.15 Considerando os idiomas que o entrevistado fala e o conjunto de idiomas da "
	note eligi15: "1.15 Considerando os idiomas que o entrevistado fala e o conjunto de idiomas da equipe de pesquisa, a entrevista pode continuar?"
	label define eligi15 1 "Sim" 0 "Não [Não entreviste essa pessoa, explique a razão e termine a entrevista.]"
	label values eligi15 eligi15

	label variable eligi16 "1.16 Em que língua vai responder a respondente."
	note eligi16: "1.16 Em que língua vai responder a respondente."
	label define eligi16 1 "Creolo" 2 "Português" 3 "Fula" 4 "Mandinga" 5 "Manjaco" 6 "Mancanha" 7 "Papel" 8 "Beafada" 9 "Felupe" 10 "Balanta" 11 "Balanta Mané" 12 "Nalu Sussu" 13 "Saracolé" 14 "Bijagós" 15 "Banhus Nikanka" -777 "Outra"
	label values eligi16 eligi16

	label variable eligi16_1 "1.16.1 Especifique outra lingua"
	note eligi16_1: "1.16.1 Especifique outra lingua"

	label variable cons01 "2.1 Podemos entrevistar a \${name_respondent}? [Esta pergunta é para o(a) encarg"
	note cons01: "2.1 Podemos entrevistar a \${name_respondent}? [Esta pergunta é para o(a) encargado(a) da respondente]"
	label define cons01 1 "Sim" 0 "Não [Não entreviste essa pessoa, explique a razão e termine a entrevista.]"
	label values cons01 cons01

	label variable cons02 "2.2 Você concorda em participar deste inquérito? [Esta pergunta é para a respond"
	note cons02: "2.2 Você concorda em participar deste inquérito? [Esta pergunta é para a respondente]"
	label define cons02 1 "Sim" 0 "Não [Não entreviste essa pessoa, explique a razão e termine a entrevista.]"
	label values cons02 cons02

	label variable cons03 "Você poderia gentilmente dar-me um número de telefone que eu possa usar para ent"
	note cons03: "Você poderia gentilmente dar-me um número de telefone que eu possa usar para entrar em contato consigo caso seja preciso confirmar alguma informação?"
	label define cons03 1 "Sim, meu número pessoal." 2 "Sim, o número de outra pessoa." 3 "Não."
	label values cons03 cons03

	label variable cons04 "Numero de telemovel"
	note cons04: "Numero de telemovel"

	label variable cons05 "2.5 Qual é a relação entre essa pessoa e o(a) inquerido(a)?"
	note cons05: "2.5 Qual é a relação entre essa pessoa e o(a) inquerido(a)?"
	label define cons05 1 "Filho/a" 2 "Pai ou mãe" 3 "Irmão/ã" 4 "Sobrinho/a" 5 "Avö/ó" 6 "Nora/o" 7 "Sogra/o" 8 "Neto/a" 9 "Tio/a" 10 "Primo/a" -777 "Outro"
	label values cons05 cons05

	label variable cons05_1 "2.5.1 Especifique a outra relação"
	note cons05_1: "2.5.1 Especifique a outra relação"

	label variable phone01 "2.6 Digite o primeiro contato"
	note phone01: "2.6 Digite o primeiro contato"

	label variable phone02 "2.7 Digite o segunto contato"
	note phone02: "2.7 Digite o segunto contato"

	label variable fam01 "3.1 Qual é o tipo de agregado familiar?"
	note fam01: "3.1 Qual é o tipo de agregado familiar?"
	label define fam01 1 "Monógamo" 2 "Polígamo"
	label values fam01 fam01

	label variable fam02 "3.2 Número de co-esposas"
	note fam02: "3.2 Número de co-esposas"

	label variable fam03 "3.3 Número de co-esposas que vivem na casa"
	note fam03: "3.3 Número de co-esposas que vivem na casa"

	label variable fam04 "3.4 Qual é a principal fonte de abastecimento de água?"
	note fam04: "3.4 Qual é a principal fonte de abastecimento de água?"
	label define fam04 1 "Torneira dentro de casa" 2 "Torneira fora de casa" 3 "Torneira de outra casa" 4 "Fontenário/Chafariz (Torneira pública)" 5 "Poço protegido" 6 "Poço não protegido" 7 "Ribeira/Nascente/rio/mar" 8 "Revendedores (cisternas)" -777 "Outra"
	label values fam04 fam04

	label variable fam04_1 "3.4.1 Especifique a outra principal fonte de abastecimento de água."
	note fam04_1: "3.4.1 Especifique a outra principal fonte de abastecimento de água."

	label variable fam05 "3.5 Neste agregado familiar, quantos quartos utiliza para dormir?"
	note fam05: "3.5 Neste agregado familiar, quantos quartos utiliza para dormir?"

	label variable fam06 "3.6 Esta casa é:"
	note fam06: "3.6 Esta casa é:"
	label define fam06 1 "Arrendada" 2 "Propriedade do agregado familiar" 3 "Cedida / Emprestada" -777 "Outro"
	label values fam06 fam06

	label variable fam06_1 "3.6 Esta casa é: OUTRO"
	note fam06_1: "3.6 Esta casa é: OUTRO"

	label variable fam07 "3.7 Qual é o material predominante utilizado no pavimento desta casa?"
	note fam07: "3.7 Qual é o material predominante utilizado no pavimento desta casa?"
	label define fam07 1 "Terra batida" 2 "Pranchas de madeira" 3 "Mosaico" 4 "Cimento" -777 "Outro"
	label values fam07 fam07

	label variable fam07_1 "3.7.1 Qual é o material predominante utilizado no pavimento desta casa? OUTRO"
	note fam07_1: "3.7.1 Qual é o material predominante utilizado no pavimento desta casa? OUTRO"

	label variable fam08 "3.8 Qual é o material predominante utilizado nas paredes exteriores desta casa?"
	note fam08: "3.8 Qual é o material predominante utilizado nas paredes exteriores desta casa?"
	label define fam08 1 "Pedra" 2 "Tijolo" 3 "Bloco de cimento" 4 "Adobe reforçado" 5 "Adobe" 6 "Taipe" 7 "Krintim com lama" -777 "Outro"
	label values fam08 fam08

	label variable fam08_1 "3.8.1 Qual é o material predominante utilizado nas paredes exteriores desta casa"
	note fam08_1: "3.8.1 Qual é o material predominante utilizado nas paredes exteriores desta casa? OUTRO"

	label variable fam09 "3.9 Tipo de instalação sanitária desta casa?"
	note fam09: "3.9 Tipo de instalação sanitária desta casa?"
	label define fam09 1 "Interior privativo com autoclismo / Uso exclusivo" 2 "Uso exclusivo sem dispositivo de descarga" 3 "Exterior privativo com autoclismo / Uso partilhado" 4 "Comum a várias famílias, com autoclismo / Uso partilhado" 5 "Latrina melhorada" 6 "Buraco na parcela" 7 "Sem casa de banho (mato)" -777 "Outro"
	label values fam09 fam09

	label variable fam09_1 "3.9.1 Tipo de instalação sanitária desta casa? OUTRO"
	note fam09_1: "3.9.1 Tipo de instalação sanitária desta casa? OUTRO"

	label variable fam10 "3.10 Qual é o combustível mais utilizado para cozinhar?"
	note fam10: "3.10 Qual é o combustível mais utilizado para cozinhar?"
	label define fam10 1 "Eletricidade" 2 "Gás" 3 "Petróleo" 4 "Lenha" 5 "Carvão vegetal" 6 "Aparo" 7 "Nenhum combustível" -777 "Outro"
	label values fam10 fam10

	label variable fam10_1 "3.10.1 Qual é o combustível mais utilizado para cozinhar? OUTRO"
	note fam10_1: "3.10.1 Qual é o combustível mais utilizado para cozinhar? OUTRO"

	label variable fam11 "3.11 Nesta casa há/ Alguém neste agregado familiar tem:"
	note fam11: "3.11 Nesta casa há/ Alguém neste agregado familiar tem:"

	label variable fam12 "3.12 Quantas parcelas de terra cultiváveis tem o seu agregado familiar?"
	note fam12: "3.12 Quantas parcelas de terra cultiváveis tem o seu agregado familiar?"

	label variable fam13 "3.13 Quantas destas parcelas foram cultivadas pelo agregado familiar durante os "
	note fam13: "3.13 Quantas destas parcelas foram cultivadas pelo agregado familiar durante os últimos 12 meses?"

	label variable fam14 "3.14 Qual é a superfície somada de todas as parcelas? (-888 se não aplicável)"
	note fam14: "3.14 Qual é a superfície somada de todas as parcelas? (-888 se não aplicável)"

	label variable fam14_1 "3.14.1 Que unidade você usou para medir as parcelas?"
	note fam14_1: "3.14.1 Que unidade você usou para medir as parcelas?"
	label define fam14_1 1 "hectare" 2 "metros quadrados" -999 "Não aplica" -777 "Outro: _______________"
	label values fam14_1 fam14_1

	label variable fam14_1_oth "3.14.1 Que unidade você usou para medir as parcelas? OUTRO"
	note fam14_1_oth: "3.14.1 Que unidade você usou para medir as parcelas? OUTRO"

	label variable fam15 "3.15 O que é/foi cultivado nessas parcelas?"
	note fam15: "3.15 O que é/foi cultivado nessas parcelas?"

	label variable fam15_1 "Especifique a outra cultura cultivada."
	note fam15_1: "Especifique a outra cultura cultivada."

	label variable fam16 "3.16 Nos últimos 7 dias, alguém de seu agregado familiar teve de abdicar (nao co"
	note fam16: "3.16 Nos últimos 7 dias, alguém de seu agregado familiar teve de abdicar (nao comer) o pequeno-almoço, o almoço ou o jantar porque não havia comida suficiente?"
	label define fam16 1 "Sim" 0 "Não"
	label values fam16 fam16

	label variable fam17 "3.17 Quantos dias?"
	note fam17: "3.17 Quantos dias?"

	label variable fam19 "3.19 Nos últimos 7 dias, alguém do seu agregado familiar teve de restringir o se"
	note fam19: "3.19 Nos últimos 7 dias, alguém do seu agregado familiar teve de restringir o seu consumo alimentar para que as crianças pequenas pudessem comer?"
	label define fam19 1 "Sim" 0 "Não"
	label values fam19 fam19

	label variable fam20 "3.20 Quantos dias?"
	note fam20: "3.20 Quantos dias?"

	label variable agre_fam01 "4.1 Quantas pessoas compõem esse grupo familiar?"
	note agre_fam01: "4.1 Quantas pessoas compõem esse grupo familiar?"

	label variable agre_fam01_1 "4.1.1 Quantas crianças de 0 anos - 5 anos e 11 meses"
	note agre_fam01_1: "4.1.1 Quantas crianças de 0 anos - 5 anos e 11 meses"

	label variable agre_fam01_2 "4.1.2 Quantas meninas de 6 anos - 11 anos e 11 meses"
	note agre_fam01_2: "4.1.2 Quantas meninas de 6 anos - 11 anos e 11 meses"

	label variable agre_fam01_3 "4.1.3 Quantas meninos de 6 anos - 11 anos e 11 meses"
	note agre_fam01_3: "4.1.3 Quantas meninos de 6 anos - 11 anos e 11 meses"

	label variable agre_fam01_4 "4.1.4 Quantos meninas de 12 anos - 17 anos e 11 meses"
	note agre_fam01_4: "4.1.4 Quantos meninas de 12 anos - 17 anos e 11 meses"

	label variable agre_fam01_5 "4.1.5 Quantos meninos de 12 anos - 17 anos e 11 meses"
	note agre_fam01_5: "4.1.5 Quantos meninos de 12 anos - 17 anos e 11 meses"

	label variable agre_fam01_6 "4.1.6 Quantas mulheres com 18 anos ou mais"
	note agre_fam01_6: "4.1.6 Quantas mulheres com 18 anos ou mais"

	label variable agre_fam01_7 "4.1.7 Quantos homens com 18 anos ou mais anos"
	note agre_fam01_7: "4.1.7 Quantos homens com 18 anos ou mais anos"

	label variable agre_fam04 "4.4 Qual é seu relação com o chefe do agregado familiar?"
	note agre_fam04: "4.4 Qual é seu relação com o chefe do agregado familiar?"
	label define agre_fam04 1 "Chefe Do Agregado" 2 "Cônjuge/Parceiro" 3 "Filho/Filha" 4 "Genro/Nora" 5 "Neto Ou Bisneto" 6 "Mãe /Pai" 7 "Sogro/Sogra" 8 "Irmão / Irmã" 9 "Cunhado /Cunhada" 10 "Tio / Tia" 11 "Sobrinho / Sobrinha" 12 "Doméstica (Vive No Agregado)" 13 "Criança Adotada/ Confiada/Enteado (A)" 14 "Outro (Parente)" 15 "Outro (Sem Grau De Parentesco)"
	label values agre_fam04 agre_fam04

	label variable agre_fam03 "4.3 Qual é o nome e apelido completo do mae de \${name_crianca}?"
	note agre_fam03: "4.3 Qual é o nome e apelido completo do mae de \${name_crianca}?"

	label variable agre_fam05 "4.5 Qual é a relação entre a(o) \${agre_fam03} e a(o) chefe do agregado familiar"
	note agre_fam05: "4.5 Qual é a relação entre a(o) \${agre_fam03} e a(o) chefe do agregado familiar?"
	label define agre_fam05 1 "Chefe Do Agregado" 2 "Cônjuge/Parceiro" 3 "Filho/Filha" 4 "Genro/Nora" 5 "Neto Ou Bisneto" 6 "Mãe /Pai" 7 "Sogro/Sogra" 8 "Irmão / Irmã" 9 "Cunhado /Cunhada" 10 "Tio / Tia" 11 "Sobrinho / Sobrinha" 12 "Doméstica (Vive No Agregado)" 13 "Criança Adotada/ Confiada/Enteado (A)" 14 "Outro (Parente)" 15 "Outro (Sem Grau De Parentesco)"
	label values agre_fam05 agre_fam05

	label variable agre_fam05_1 "4.6 Qual é a idade de \${agre_fam03}?"
	note agre_fam05_1: "4.6 Qual é a idade de \${agre_fam03}?"

	label variable agre_fam06 "4.7 Você tem um parceiro morando com você nesta casa?"
	note agre_fam06: "4.7 Você tem um parceiro morando com você nesta casa?"
	label define agre_fam06 1 "Sim" 0 "Não"
	label values agre_fam06 agre_fam06

	label variable agre_fam07 "4.8 Qual é o nome e apelido completo do parceiro?"
	note agre_fam07: "4.8 Qual é o nome e apelido completo do parceiro?"

	label variable agre_fam08 "4.9 Qual é a relação entre a(o) \${agre_fam07} e a(o) chefe do agregado familiar"
	note agre_fam08: "4.9 Qual é a relação entre a(o) \${agre_fam07} e a(o) chefe do agregado familiar?"
	label define agre_fam08 1 "Chefe Do Agregado" 2 "Cônjuge/Parceiro" 3 "Filho/Filha" 4 "Genro/Nora" 5 "Neto Ou Bisneto" 6 "Mãe /Pai" 7 "Sogro/Sogra" 8 "Irmão / Irmã" 9 "Cunhado /Cunhada" 10 "Tio / Tia" 11 "Sobrinho / Sobrinha" 12 "Doméstica (Vive No Agregado)" 13 "Criança Adotada/ Confiada/Enteado (A)" 14 "Outro (Parente)" 15 "Outro (Sem Grau De Parentesco)"
	label values agre_fam08 agre_fam08

	label variable agre_fam09 "4.10 Qual é a idade de \${agre_fam07}?"
	note agre_fam09: "4.10 Qual é a idade de \${agre_fam07}?"

	label variable agre_fam14 "4.11 \${agre_fam07} é o pai de \${name_crianca}?"
	note agre_fam14: "4.11 \${agre_fam07} é o pai de \${name_crianca}?"
	label define agre_fam14 1 "Sim" 0 "Não"
	label values agre_fam14 agre_fam14

	label variable agre_fam15 "4.12 Qual é o nome e apelido completo do pai de \${name_crianca}?"
	note agre_fam15: "4.12 Qual é o nome e apelido completo do pai de \${name_crianca}?"

	label variable agre_fam16 "4.13 Qual é a relação entre a(o) \${agre_fam15} e a(o) chefe do agregado familia"
	note agre_fam16: "4.13 Qual é a relação entre a(o) \${agre_fam15} e a(o) chefe do agregado familiar?"
	label define agre_fam16 1 "Chefe Do Agregado" 2 "Cônjuge/Parceiro" 3 "Filho/Filha" 4 "Genro/Nora" 5 "Neto Ou Bisneto" 6 "Mãe /Pai" 7 "Sogro/Sogra" 8 "Irmão / Irmã" 9 "Cunhado /Cunhada" 10 "Tio / Tia" 11 "Sobrinho / Sobrinha" 12 "Doméstica (Vive No Agregado)" 13 "Criança Adotada/ Confiada/Enteado (A)" 14 "Outro (Parente)" 15 "Outro (Sem Grau De Parentesco)"
	label values agre_fam16 agre_fam16

	label variable agre_fam17 "4.14 Qual é a idade de \${agre_fam15}?"
	note agre_fam17: "4.14 Qual é a idade de \${agre_fam15}?"

	label variable agre_fam10 "4.15 Quantos filhos você tem que moram com você nesta casa, excluindo \${name_cr"
	note agre_fam10: "4.15 Quantos filhos você tem que moram com você nesta casa, excluindo \${name_crianca}?"

	label variable agre_fam18 "4.19 Sua mãe mora neste agregado familiar?"
	note agre_fam18: "4.19 Sua mãe mora neste agregado familiar?"
	label define agre_fam18 1 "Sim" 0 "Não"
	label values agre_fam18 agre_fam18

	label variable agre_fam19 "4.20 Qual é o nome e apelido completo do sua mãe?"
	note agre_fam19: "4.20 Qual é o nome e apelido completo do sua mãe?"

	label variable agre_fam20 "4.21 Qual é a relação entre a(o) \${agre_fam19} e a(o) chefe do agregado familia"
	note agre_fam20: "4.21 Qual é a relação entre a(o) \${agre_fam19} e a(o) chefe do agregado familiar?"
	label define agre_fam20 1 "Chefe Do Agregado" 2 "Cônjuge/Parceiro" 3 "Filho/Filha" 4 "Genro/Nora" 5 "Neto Ou Bisneto" 6 "Mãe /Pai" 7 "Sogro/Sogra" 8 "Irmão / Irmã" 9 "Cunhado /Cunhada" 10 "Tio / Tia" 11 "Sobrinho / Sobrinha" 12 "Doméstica (Vive No Agregado)" 13 "Criança Adotada/ Confiada/Enteado (A)" 14 "Outro (Parente)" 15 "Outro (Sem Grau De Parentesco)"
	label values agre_fam20 agre_fam20

	label variable agre_fam21 "4.22 Qual é a idade de \${agre_fam19}?"
	note agre_fam21: "4.22 Qual é a idade de \${agre_fam19}?"

	label variable agre_fam22 "4.23 Seu pai mora neste agregado familiar?"
	note agre_fam22: "4.23 Seu pai mora neste agregado familiar?"
	label define agre_fam22 1 "Sim" 0 "Não"
	label values agre_fam22 agre_fam22

	label variable agre_fam23 "4.24 Qual é o nome e apelido completo do seu pai?"
	note agre_fam23: "4.24 Qual é o nome e apelido completo do seu pai?"

	label variable agre_fam24 "4.25 Qual é a relação entre a(o) \${agre_fam22} e a(o) chefe do agregado familia"
	note agre_fam24: "4.25 Qual é a relação entre a(o) \${agre_fam22} e a(o) chefe do agregado familiar?"
	label define agre_fam24 1 "Chefe Do Agregado" 2 "Cônjuge/Parceiro" 3 "Filho/Filha" 4 "Genro/Nora" 5 "Neto Ou Bisneto" 6 "Mãe /Pai" 7 "Sogro/Sogra" 8 "Irmão / Irmã" 9 "Cunhado /Cunhada" 10 "Tio / Tia" 11 "Sobrinho / Sobrinha" 12 "Doméstica (Vive No Agregado)" 13 "Criança Adotada/ Confiada/Enteado (A)" 14 "Outro (Parente)" 15 "Outro (Sem Grau De Parentesco)"
	label values agre_fam24 agre_fam24

	label variable agre_fam25 "4.26 Qual é a idade de \${agre_fam22}?"
	note agre_fam25: "4.26 Qual é a idade de \${agre_fam22}?"

	label variable mae08 "5.8 Qual é o seu atual estado civil?"
	note mae08: "5.8 Qual é o seu atual estado civil?"
	label define mae08 1 "Solteira" 2 "Casada o em união livre" 3 "Separada ou divorciada" 4 "Viúva"
	label values mae08 mae08

	label variable mae09 "5.9 Qual é a sua etnia?"
	note mae09: "5.9 Qual é a sua etnia?"
	label define mae09 1 "Sem etnia" 2 "Fula" 3 "Mandinga" 4 "Manjaco" 5 "Mancanha" 6 "Papel" 7 "Beafada" 8 "Felupe" 9 "Balanta" 10 "Balanta Mané" 11 "Nalu" 12 "Sussu" 13 "Saracolé" 14 "Bijagós" -777 "Outra"
	label values mae09 mae09

	label variable mae09_1 "5.9.1 Descreva a outra etnia."
	note mae09_1: "5.9.1 Descreva a outra etnia."

	label variable mae10 "5.10 Você sabe ler e escrever?"
	note mae10: "5.10 Você sabe ler e escrever?"
	label define mae10 1 "Sim" 0 "Não"
	label values mae10 mae10

	label variable mae11 "5.11 Você frequenta atualmente uma escola formal?"
	note mae11: "5.11 Você frequenta atualmente uma escola formal?"
	label define mae11 1 "Sim" 0 "Não"
	label values mae11 mae11

	label variable mae12 "5.12 Qual é o nível de ensino mais elevado que você atingiu?"
	note mae12: "5.12 Qual é o nível de ensino mais elevado que você atingiu?"
	label define mae12 1 "Pré-escolar ou nenhum" 2 "Ensino básico 1º ciclo completo" 3 "Ensino básico 2º ciclo completo" 4 "Ensino básico 3º ciclo completo" 5 "Ensino secundário 9 completo" 6 "Ensino secundário 10 completo" 7 "Ensino secundário 11 completo" 8 "Ensino secundário 12 completo" 9 "Ensino técnico profissional incompleto" 10 "Ensino técnico profissional completo" 11 "Bacharelato incompleto" 12 "Bacharelato completo" 13 "Licenciatura incompleta" 14 "Licenciatura completa" 15 "Mestrado ou Doutorado incompleto" 16 "Mestrado ou Doutorado completo"
	label values mae12 mae12

	label variable mae14 "5.13 Há quantos anos você mora nesta tabanca? Se a pessoa mora na tabanca desde "
	note mae14: "5.13 Há quantos anos você mora nesta tabanca? Se a pessoa mora na tabanca desde o nascimento, informe a idade dela."

	label variable emprego01 "6.1 Nos últimos 7 dias, você realizou alguma atividade econômica (remunerada ou "
	note emprego01: "6.1 Nos últimos 7 dias, você realizou alguma atividade econômica (remunerada ou não)?"
	label define emprego01 1 "Sim" 0 "Não"
	label values emprego01 emprego01

	label variable emprego02 "6.2 Embora você não tenha trabalhado nos últimos 7 dias, você tem alguma ocupaçã"
	note emprego02: "6.2 Embora você não tenha trabalhado nos últimos 7 dias, você tem alguma ocupação que deveria ter realizado nesse período?"
	label define emprego02 1 "Sim" 0 "Não"
	label values emprego02 emprego02

	label variable emprego03 "6.3 Qual foi a principal atividade que você deveria ter realizado nos últimos 7 "
	note emprego03: "6.3 Qual foi a principal atividade que você deveria ter realizado nos últimos 7 dias, mas não realizou? [Marque apenas uma opção]"
	label define emprego03 1 "Colheita de caju em terreno próprio" 2 "Colheita de caju em terreno NÃO próprio" 3 "Trabalho agrícola ou pecuário em terreno próprio" 4 "Trabalho agrícola ou pecuário em terreno NÃO próprio" 5 "Transformação de produtos agrícolas ou pecuários em terreno próprio" 6 "Transformação de produtos agrícolas ou pecuários em terreno NÃO próprio" 7 "Venda de produtos agrícolas" 8 "Comércio de produtos não agrícolas" 9 "Trabalhador de mina" 10 "Transporte" 11 "Artesanato/costura" 12 "Professor(a)" 13 "Enfermeiro(a)" 14 "Trabalho doméstico (fora do agregado familiar)" 15 "Cuidados infantis (fora do agregado familiar)" -777 "Outra atividade não agrícola (especifique)"
	label values emprego03 emprego03

	label variable emprego03_oth "6.3 Qual foi a principal atividade que você deveria ter realizado nos últimos 7 "
	note emprego03_oth: "6.3 Qual foi a principal atividade que você deveria ter realizado nos últimos 7 dias, mas não realizou? OUTRO"

	label variable emprego04 "6.4 Por que você não realizou essa atividade nos últimos 7 dias?"
	note emprego04: "6.4 Por que você não realizou essa atividade nos últimos 7 dias?"
	label define emprego04 1 "Licença, férias" 2 "Licença maternidade" 3 "Parada temporária por conta própria" 4 "Licença médica" 5 "Outra suspensão temporária" 6 "Em formação ou estágio" -777 "Outro (especifique):"
	label values emprego04 emprego04

	label variable emprego04_oth "6.4 Por que você não realizou essa atividade nos últimos 7 dias? OUTRO"
	note emprego04_oth: "6.4 Por que você não realizou essa atividade nos últimos 7 dias? OUTRO"

	label variable emprego05 "6.5 Você realizou alguma ação nos últimos 7 dias para procurar trabalho?"
	note emprego05: "6.5 Você realizou alguma ação nos últimos 7 dias para procurar trabalho?"
	label define emprego05 1 "Sim" 0 "Não"
	label values emprego05 emprego05

	label variable emprego06 "6.6 Qual é o principal motivo pelo qual você não procurou trabalho nos últimos 7"
	note emprego06: "6.6 Qual é o principal motivo pelo qual você não procurou trabalho nos últimos 7 dias?"
	label define emprego06 1 "Estudante" 2 "Dedicado(a) aos cuidados da casa/crianças" 3 "Idoso(a)/aposentado(a)" 4 "Doença/dor" 5 "Deficiência" 6 "Aguardando resposta de empregador" 7 "Aguardando chamada de empregador" 8 "De licença" 9 "Aguardando alta temporada" -777 "Outro (especifique):"
	label values emprego06 emprego06

	label variable emprego06_oth "6.6 Qual é o principal motivo pelo qual você não procurou trabalho nos últimos 7"
	note emprego06_oth: "6.6 Qual é o principal motivo pelo qual você não procurou trabalho nos últimos 7 dias? OUTRO"

	label variable emprego07 "6.7 Qual foi a principal atividade que você realizou nos últimos 7 dias? [Marque"
	note emprego07: "6.7 Qual foi a principal atividade que você realizou nos últimos 7 dias? [Marque apenas uma opção]"
	label define emprego07 1 "Colheita de caju em terreno próprio" 2 "Colheita de caju em terreno NÃO próprio" 3 "Trabalho agrícola ou pecuário em terreno próprio" 4 "Trabalho agrícola ou pecuário em terreno NÃO próprio" 5 "Transformação de produtos agrícolas ou pecuários em terreno próprio" 6 "Transformação de produtos agrícolas ou pecuários em terreno NÃO próprio" 7 "Venda de produtos agrícolas" 8 "Comércio de produtos não agrícolas" 9 "Trabalhador de mina" 10 "Transporte" 11 "Artesanato/costura" 12 "Professor(a)" 13 "Enfermeiro(a)" 14 "Trabalho doméstico (fora do agregado familiar)" 15 "Cuidados infantis (fora do agregado familiar)" -777 "Outra atividade não agrícola (especifique)"
	label values emprego07 emprego07

	label variable emprego07_oth "6.7 Qual foi a principal atividade que você realizou nos últimos 7 dias? OUTRO"
	note emprego07_oth: "6.7 Qual foi a principal atividade que você realizou nos últimos 7 dias? OUTRO"

	label variable emprego08 "6.8 Essa atividade principal foi remunerada? [Selecione todas as opções que se a"
	note emprego08: "6.8 Essa atividade principal foi remunerada? [Selecione todas as opções que se aplicam]"

	label variable emprego09 "6.9 Quanto você recebeu pelo seu trabalho dos últimos 7 dias?"
	note emprego09: "6.9 Quanto você recebeu pelo seu trabalho dos últimos 7 dias?"

	label variable emprego10 "6.10 Quanto você espera receber pelo seu trabalho dos últimos 7 dias?."
	note emprego10: "6.10 Quanto você espera receber pelo seu trabalho dos últimos 7 dias?."

	label variable emprego11 "6.11 Quando você espera receber o pagamento?"
	note emprego11: "6.11 Quando você espera receber o pagamento?"
	label define emprego11 1 "Esta semana" 2 "No final do mês" 3 "Ao final do trabalho" -777 "Outro"
	label values emprego11 emprego11

	label variable emprego11_oth "6.11.1 Quando você espera receber o pagamento? OUTRO"
	note emprego11_oth: "6.11.1 Quando você espera receber o pagamento? OUTRO"

	label variable emprego12 "6.12 Se você tivesse que vender tudo o que recebeu em espécie nos últimos 7 dias"
	note emprego12: "6.12 Se você tivesse que vender tudo o que recebeu em espécie nos últimos 7 dias, quanto receberia aproximadamente?"

	label variable emprego13 "6.13 Qual é o principal motivo de não ter recebido pagamento por esse trabalho?"
	note emprego13: "6.13 Qual é o principal motivo de não ter recebido pagamento por esse trabalho?"

	label variable emprego14 "6.14 Aproximadamente, quantas horas você dedicou a essa atividade principal nos "
	note emprego14: "6.14 Aproximadamente, quantas horas você dedicou a essa atividade principal nos últimos 7 dias?"
	label define emprego14 1 "Menos de 10 horas" 2 "Entre 10 e 19 horas" 3 "Entre 20 e 29 horas" 4 "Entre 30 e 39 horas" 5 "40 horas ou mais"
	label values emprego14 emprego14

	label variable emprego15 "6.15 Na sua atividade principal nos últimos 7 dias, você trabalhou com algum tip"
	note emprego15: "6.15 Na sua atividade principal nos últimos 7 dias, você trabalhou com algum tipo de contrato escrito ou formal?"
	label define emprego15 1 "Sim" 0 "Não" -888 "Não sabe"
	label values emprego15 emprego15

	label variable emprego16 "6.16 Você realizou alguma outra atividade económica secundária (remunerada ou nã"
	note emprego16: "6.16 Você realizou alguma outra atividade económica secundária (remunerada ou não) nos últimos 7 dias?"
	label define emprego16 1 "Sim" 0 "Não"
	label values emprego16 emprego16

	label variable emprego17 "6.17 Qual foi essa atividade secundária? (principal actividade secundária)"
	note emprego17: "6.17 Qual foi essa atividade secundária? (principal actividade secundária)"
	label define emprego17 1 "Colheita de caju em terreno próprio" 2 "Colheita de caju em terreno NÃO próprio" 3 "Trabalho agrícola ou pecuário em terreno próprio" 4 "Trabalho agrícola ou pecuário em terreno NÃO próprio" 5 "Transformação de produtos agrícolas ou pecuários em terreno próprio" 6 "Transformação de produtos agrícolas ou pecuários em terreno NÃO próprio" 7 "Venda de produtos agrícolas" 8 "Comércio de produtos não agrícolas" 9 "Trabalhador de mina" 10 "Transporte" 11 "Artesanato/costura" 12 "Professor(a)" 13 "Enfermeiro(a)" 14 "Trabalho doméstico (fora do agregado familiar)" 15 "Cuidados infantis (fora do agregado familiar)" -777 "Outra atividade não agrícola (especifique)"
	label values emprego17 emprego17

	label variable emprego17_oth "6.16 Qual foi essa atividade secundária? (principal actividade secundária) OUTRO"
	note emprego17_oth: "6.16 Qual foi essa atividade secundária? (principal actividade secundária) OUTRO"

	label variable emprego18 "6.18 Essa atividade secundária foi remunerada? [Selecione todas as opções que se"
	note emprego18: "6.18 Essa atividade secundária foi remunerada? [Selecione todas as opções que se aplicam]"

	label variable emprego19 "6.19 Quantas horas aproximadamente você dedicou-se a essa atividade secundária, "
	note emprego19: "6.19 Quantas horas aproximadamente você dedicou-se a essa atividade secundária, nos últimos 7 dias?"
	label define emprego19 1 "Menos de 10 horas" 2 "Entre 10 e 19 horas" 3 "Entre 20 e 29 horas" 4 "Entre 30 e 39 horas" 5 "40 horas ou mais"
	label values emprego19 emprego19

	label variable tempo01 "7.1 A que horas você acordou ontem?"
	note tempo01: "7.1 A que horas você acordou ontem?"

	label variable tempo02 "7.2 A que horas você foi dormir ontem?"
	note tempo02: "7.2 A que horas você foi dormir ontem?"

	label variable tempo06 "7.6 Em qual(is) atividade(s) fora de casa você trabalhou ontem? [Selecione todas"
	note tempo06: "7.6 Em qual(is) atividade(s) fora de casa você trabalhou ontem? [Selecione todas as opções que se aplicam]"

	label variable tempo06_oth "7.6 Em qual(is) atividade(s) fora de casa você trabalhou ontem? [Selecione todas"
	note tempo06_oth: "7.6 Em qual(is) atividade(s) fora de casa você trabalhou ontem? [Selecione todas as opções que se aplicam]: OUTRO"

	label variable tempo07 "7.7 Quais tarefas domésticas você realizou ontem? [Selecione todas as opções que"
	note tempo07: "7.7 Quais tarefas domésticas você realizou ontem? [Selecione todas as opções que se aplicam]"

	label variable tempo07_oth "7.7 Quais tarefas domésticas você realizou ontem? [Selecione todas as opções que"
	note tempo07_oth: "7.7 Quais tarefas domésticas você realizou ontem? [Selecione todas as opções que se aplicam]: OUTRO"

	label variable tempo08 "7.8 Quais atividades de cuidados com outrem, vocês realizou ontem? [Selecione to"
	note tempo08: "7.8 Quais atividades de cuidados com outrem, vocês realizou ontem? [Selecione todas as opções que se aplicam]."

	label variable tempo08_oth "7.8 Quais atividades de cuidado você realizou ontem? [Selecione todas as opções "
	note tempo08_oth: "7.8 Quais atividades de cuidado você realizou ontem? [Selecione todas as opções que se aplicam]: OUTRO"

	label variable tempo09 "7.9 Quais atividades de descanso ou lazer você realizou ontem? [Selecione todas "
	note tempo09: "7.9 Quais atividades de descanso ou lazer você realizou ontem? [Selecione todas as opções que se aplicam]"

	label variable tempo09_oth "7.9 Quais atividades de descanso ou lazer você realizou ontem? [Selecione todas "
	note tempo09_oth: "7.9 Quais atividades de descanso ou lazer você realizou ontem? [Selecione todas as opções que se aplicam]: OUTRO"

	label variable decisao01 "8.1 Que peso tem na tomada de decisões sobre [como é gasto o dinheiro do agregad"
	note decisao01: "8.1 Que peso tem na tomada de decisões sobre [como é gasto o dinheiro do agregado familiar] no seio do agregado familiar?"
	label define decisao01 1 "Em nenhuma ou muito poucas decisões" 2 "Em algumas decisões" 3 "Em quase todas as decisões" -999 "Não se aplica"
	label values decisao01 decisao01

	label variable decisao02 "8.2 Está satisfeito com o peso que tem na tomada de decisões sobre [como é gasto"
	note decisao02: "8.2 Está satisfeito com o peso que tem na tomada de decisões sobre [como é gasto o dinheiro do agregado familiar] no seio do agregado familiar ou gostaria de ter mais ou menos influência?"
	label define decisao02 1 "Mais" 2 "Estou feliz assim" 3 "Menos"
	label values decisao02 decisao02

	label variable decisao03 "8.3 Em que medida sente que pode tomar as suas próprias decisões relativamente ["
	note decisao03: "8.3 Em que medida sente que pode tomar as suas próprias decisões relativamente [à forma como o dinheiro do agregado familiar é gasto], se assim o desejar, no seio do agregado familiar?"
	label define decisao03 1 "De modo algum" 2 "Um pouco" 3 "Moderadamente" 4 "Bastante"
	label values decisao03 decisao03

	label variable decisao04 "8.4 Qual é o seu peso na tomada de decisões relativas a [empréstimos contraídos "
	note decisao04: "8.4 Qual é o seu peso na tomada de decisões relativas a [empréstimos contraídos pelo agregado familiar] no seio do agregado familiar?"
	label define decisao04 1 "Em nenhuma ou muito poucas decisões" 2 "Em algumas decisões" 3 "Em quase todas as decisões" -999 "Não se aplica"
	label values decisao04 decisao04

	label variable decisao05 "8.5 Em que medida sente que pode tomar as suas próprias decisões relativamente a"
	note decisao05: "8.5 Em que medida sente que pode tomar as suas próprias decisões relativamente a [empréstimos contraídos pelo agregado familiar], se assim o desejar, no seio do agregado familiar?"
	label define decisao05 1 "De modo algum" 2 "Um pouco" 3 "Moderadamente" 4 "Bastante"
	label values decisao05 decisao05

	label variable decisao06 "8.6 Quando você ganha dinheiro, quem decide como ele será usado?"
	note decisao06: "8.6 Quando você ganha dinheiro, quem decide como ele será usado?"
	label define decisao06 1 "Apenas ela mesma" 2 "O seu cônjuge/companheiro influência, mas ela decide" 3 "O seu cônjuge/companheiro decide como o dinheiro dela será gasto" 4 "Decidem juntos" -777 "Outro: ___________"
	label values decisao06 decisao06

	label variable decisao06_oth "8.6 Quando você ganha dinheiro, quem decide como ele será usado? OUTRO"
	note decisao06_oth: "8.6 Quando você ganha dinheiro, quem decide como ele será usado? OUTRO"

	label variable decisao07 "8.7 Quando o pai da criança ganha dinheiro, quem decide como ele será usado?"
	note decisao07: "8.7 Quando o pai da criança ganha dinheiro, quem decide como ele será usado?"
	label define decisao07 1 "Apenas ele mesmo" 2 "A mãe tem influência, mas ele decide" 3 "A mãe decide como o dinheiro dele será gasto" 4 "Decidem juntos" -777 "Outro: __________"
	label values decisao07 decisao07

	label variable decisao07_oth "8.7 Quando o pai da criança ganha dinheiro, quem decide como ele será usado? OUT"
	note decisao07_oth: "8.7 Quando o pai da criança ganha dinheiro, quem decide como ele será usado? OUTRO"

	label variable decisao08 "8.8 Quem decide sobre os gastos com a educação de \${name_crianca}? (Exemplos de"
	note decisao08: "8.8 Quem decide sobre os gastos com a educação de \${name_crianca}? (Exemplos de gastos: pagamento do jardim, materiais escolares)"
	label define decisao08 1 "Apenas o pai" 2 "Apenas a mãe" 3 "Ambos decidem e têm o mesmo peso na decisão" 4 "Ambos decidem mas o pai têm mais peso na decisão" 5 "Ambos decidem mas a mãe têm mais peso na decisão" -777 "Outro: ___________"
	label values decisao08 decisao08

	label variable decisao08_oth "8.8 Quem decide sobre os gastos com a educação de \${name_crianca}? (Exemplos de"
	note decisao08_oth: "8.8 Quem decide sobre os gastos com a educação de \${name_crianca}? (Exemplos de gastos: pagamento do jardim, materiais escolares) OUTRO"

	label variable decisao09 "8.9 Quem decide sobre os gastos com saúde e alimentação de \${name_crianca}?"
	note decisao09: "8.9 Quem decide sobre os gastos com saúde e alimentação de \${name_crianca}?"
	label define decisao09 1 "Apenas o pai" 2 "Apenas a mãe" 3 "Ambos decidem e têm o mesmo peso na decisão" 4 "Ambos decidem mas o pai têm mais peso na decisão" 5 "Ambos decidem mas a mãe têm mais peso na decisão" -777 "Outro: ___________"
	label values decisao09 decisao09

	label variable decisao09_oth "8.9 Quem decide sobre os gastos com saúde e alimentação de \${name_crianca}? OUT"
	note decisao09_oth: "8.9 Quem decide sobre os gastos com saúde e alimentação de \${name_crianca}? OUTRO"

	label variable decisao10 "8.10 Você tem acesso independente ao dinheiro do agregado familiar (ex.: ter pou"
	note decisao10: "8.10 Você tem acesso independente ao dinheiro do agregado familiar (ex.: ter poupança própria, guardar parte dos rendimentos para si mesma)?"
	label define decisao10 1 "Sim, tem total autonomia sobre suas finanças" 2 "Sim, mas seu cônjuge/companheiro precisa ser informado" 3 "Não, ela não tem controle sobre o dinheiro" -777 "Outro: ___________"
	label values decisao10 decisao10

	label variable decisao10_oth "8.10 Você tem acesso independente ao dinheiro do agregado familiar (ex.: ter pou"
	note decisao10_oth: "8.10 Você tem acesso independente ao dinheiro do agregado familiar (ex.: ter poupança própria, guardar parte dos rendimentos para si mesma)? OUTRO"

	label variable decisao11 "8.11 Deixando de lado a ajuda que recebe de outros membros do seu agregado famil"
	note decisao11: "8.11 Deixando de lado a ajuda que recebe de outros membros do seu agregado familiar, como é que você e o seu parceiro concordam em partilhar a tarefa [Preparar os alimentos]?"
	label define decisao11 1 "Eu faço tudo" 2 "Eu ocupo-me mais frequentemente." 3 "Partilhamos a tarefa em partes iguais" 4 "O meu parceiro ocupa-se mais frequentemente" 5 "Ele faz tudo"
	label values decisao11 decisao11

	label variable decisao12 "8.12 Deixando de lado a ajuda que recebe de outros membros do seu agregado famil"
	note decisao12: "8.12 Deixando de lado a ajuda que recebe de outros membros do seu agregado familiar, como é que você e o seu parceiro concordam em partilhar as tarefas [Limpar a casa e lavar a roupa]?"
	label define decisao12 1 "Eu faço tudo" 2 "Eu ocupo-me mais frequentemente." 3 "Partilhamos a tarefa em partes iguais" 4 "O meu parceiro ocupa-se mais frequentemente" 5 "Ele faz tudo"
	label values decisao12 decisao12

	label variable decisao13 "8.13 Deixando de lado a ajuda que recebe de outros membros do seu agregado famil"
	note decisao13: "8.13 Deixando de lado a ajuda que recebe de outros membros do seu agregado familiar, como é que você e o seu parceiro concordam em partilhar a tarefa [Cuidados infantis]?"
	label define decisao13 1 "Eu faço tudo" 2 "Eu ocupo-me mais frequentemente." 3 "Partilhamos a tarefa em partes iguais" 4 "O meu parceiro ocupa-se mais frequentemente" 5 "Ele faz tudo"
	label values decisao13 decisao13

	label variable decisao14 "8.14 Nos últimos 12 meses, o seu cônjuge/companheiro(a) ou outro membro do seu a"
	note decisao14: "8.14 Nos últimos 12 meses, o seu cônjuge/companheiro(a) ou outro membro do seu agregado familiar impediu-o(a) de visitar familiares ou amigos?"
	label define decisao14 1 "Sim" 0 "Não" -999 "Não quer responder"
	label values decisao14 decisao14

	label variable decisao15 "8.15 Nos últimos 12 meses, o seu cônjuge/companheiro(a) ou outro membro do agreg"
	note decisao15: "8.15 Nos últimos 12 meses, o seu cônjuge/companheiro(a) ou outro membro do agregado familiar impediu-o(a) de trabalhar fora de casa?"
	label define decisao15 1 "Sim" 0 "Não" -999 "Não quer responder"
	label values decisao15 decisao15

	label variable decisao16 "8.16 Na sua opinião, justifica-se que um marido bata ou espanque a sua mulher se"
	note decisao16: "8.16 Na sua opinião, justifica-se que um marido bata ou espanque a sua mulher se ela queimar a comida?"
	label define decisao16 1 "Sim" 0 "Não" -999 "Não quer responder"
	label values decisao16 decisao16

	label variable decisao17 "8.17 Na sua opinião, justifica-se que um marido bata ou espanque a sua mulher se"
	note decisao17: "8.17 Na sua opinião, justifica-se que um marido bata ou espanque a sua mulher se ela negligenciar os filhos?"
	label define decisao17 1 "Sim" 0 "Não" -999 "Não quer responder"
	label values decisao17 decisao17

	label variable estres01 "9.1.1 Sinto-me feliz no meu papel de mãe/pai"
	note estres01: "9.1.1 Sinto-me feliz no meu papel de mãe/pai"
	label define estres01 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres01 estres01

	label variable estres02 "9.1.2 Há pouca ou nenhuma coisa que eu não faria pelo(s) meu(s) filho(s) se foss"
	note estres02: "9.1.2 Há pouca ou nenhuma coisa que eu não faria pelo(s) meu(s) filho(s) se fosse necessário."
	label define estres02 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres02 estres02

	label variable estres03 "9.1.3 Cuidar do(s) meu(s) filho(s) exige, por vezes, mais tempo e energia do que"
	note estres03: "9.1.3 Cuidar do(s) meu(s) filho(s) exige, por vezes, mais tempo e energia do que eu tenho para dar."
	label define estres03 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres03 estres03

	label variable estres04 "9.1.4 Por vezes preocupo-me se estou a fazer o suficiente pelo(s) meu(s) filho(s"
	note estres04: "9.1.4 Por vezes preocupo-me se estou a fazer o suficiente pelo(s) meu(s) filho(s)."
	label define estres04 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres04 estres04

	label variable estres05 "9.1.5 Sinto-me próximo do(s) meu(s) filho(s)."
	note estres05: "9.1.5 Sinto-me próximo do(s) meu(s) filho(s)."
	label define estres05 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres05 estres05

	label variable estres06 "9.1.6 Gosto de passar tempo com o(s) meu(s) filho(s)."
	note estres06: "9.1.6 Gosto de passar tempo com o(s) meu(s) filho(s)."
	label define estres06 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres06 estres06

	label variable estres07 "9.1.7 O(s) meu(s) filho(s) é(são) uma importante fonte de afeto para mim."
	note estres07: "9.1.7 O(s) meu(s) filho(s) é(são) uma importante fonte de afeto para mim."
	label define estres07 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres07 estres07

	label variable estres08 "9.1.8 Ter filho(s) dá-me uma visão mais segura e otimista do futuro."
	note estres08: "9.1.8 Ter filho(s) dá-me uma visão mais segura e otimista do futuro."
	label define estres08 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres08 estres08

	label variable estres09 "9.1.9 A maior fonte de stress na minha vida é o(s) meu(s) filho(s)."
	note estres09: "9.1.9 A maior fonte de stress na minha vida é o(s) meu(s) filho(s)."
	label define estres09 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres09 estres09

	label variable estres10 "9.1.10 Ter filho(s) deixa pouco tempo e flexibilidade na minha vida."
	note estres10: "9.1.10 Ter filho(s) deixa pouco tempo e flexibilidade na minha vida."
	label define estres10 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres10 estres10

	label variable estres11 "9.1.11 Ter filho(s) tem sido um encargo financeiro."
	note estres11: "9.1.11 Ter filho(s) tem sido um encargo financeiro."
	label define estres11 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres11 estres11

	label variable estres12 "9.1.12 É difícil equilibrar diferentes responsabilidades por causa do(s) meu(s) "
	note estres12: "9.1.12 É difícil equilibrar diferentes responsabilidades por causa do(s) meu(s) filho(s)."
	label define estres12 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres12 estres12

	label variable estres13 "9.1.13 O comportamento do(s) meu(s) filho(s) é frequentemente embaraçoso ou estr"
	note estres13: "9.1.13 O comportamento do(s) meu(s) filho(s) é frequentemente embaraçoso ou estressante para mim."
	label define estres13 1 "Discordo totalmente" 2 "Discordo" 3 "Incerto" 4 "Concordo" 5 "Concordo totalmente"
	label values estres13 estres13

	label variable ansiedad01 "10.1.1 Sentir-se nervoso, ansioso ou nervoso"
	note ansiedad01: "10.1.1 Sentir-se nervoso, ansioso ou nervoso"
	label define ansiedad01 0 "De modo algum" 1 "Vários dias" 2 "Mais de metades dos dias" 3 "Quase todos os dias"
	label values ansiedad01 ansiedad01

	label variable ansiedad02 "10.1.2 Não ser capaz de parar ou controlar a preocupação"
	note ansiedad02: "10.1.2 Não ser capaz de parar ou controlar a preocupação"
	label define ansiedad02 0 "De modo algum" 1 "Vários dias" 2 "Mais de metades dos dias" 3 "Quase todos os dias"
	label values ansiedad02 ansiedad02

	label variable ansiedad03 "10.1.3 Preocupar-se demasiado com coisas diferentes"
	note ansiedad03: "10.1.3 Preocupar-se demasiado com coisas diferentes"
	label define ansiedad03 0 "De modo algum" 1 "Vários dias" 2 "Mais de metades dos dias" 3 "Quase todos os dias"
	label values ansiedad03 ansiedad03

	label variable ansiedad04 "10.1.4 Problemas de relaxamento"
	note ansiedad04: "10.1.4 Problemas de relaxamento"
	label define ansiedad04 0 "De modo algum" 1 "Vários dias" 2 "Mais de metades dos dias" 3 "Quase todos os dias"
	label values ansiedad04 ansiedad04

	label variable ansiedad05 "10.1.5 Estar tão irrequieto que é difícil ficar quieto"
	note ansiedad05: "10.1.5 Estar tão irrequieto que é difícil ficar quieto"
	label define ansiedad05 0 "De modo algum" 1 "Vários dias" 2 "Mais de metades dos dias" 3 "Quase todos os dias"
	label values ansiedad05 ansiedad05

	label variable ansiedad06 "10.1.6 Irritação ou aborrecimento fácil"
	note ansiedad06: "10.1.6 Irritação ou aborrecimento fácil"
	label define ansiedad06 0 "De modo algum" 1 "Vários dias" 2 "Mais de metades dos dias" 3 "Quase todos os dias"
	label values ansiedad06 ansiedad06

	label variable ansiedad07 "10.1.7 Sentir medo como se algo terrível pudesse acontecer"
	note ansiedad07: "10.1.7 Sentir medo como se algo terrível pudesse acontecer"
	label define ansiedad07 0 "De modo algum" 1 "Vários dias" 2 "Mais de metades dos dias" 3 "Quase todos os dias"
	label values ansiedad07 ansiedad07

	label variable crianca01 "11.1 Em que data nasceu \${name_crianca}?"
	note crianca01: "11.1 Em que data nasceu \${name_crianca}?"

	label variable crianca02 "11.2 Quantos anos completos tem \${name_crianca}? [Por exemplo, se a criança tem"
	note crianca02: "11.2 Quantos anos completos tem \${name_crianca}? [Por exemplo, se a criança tem 5 anos e 11 meses, escreva 5 anos.]"

	label variable crianca03 "11.3 Em qual região a(o) \${name_crianca} nasceu?"
	note crianca03: "11.3 Em qual região a(o) \${name_crianca} nasceu?"
	label define crianca03 1 "Tombali" 2 "Quinara" 3 "Oio" 4 "Biombo" 5 "Bafata" 6 "Gabu" 7 "Cacheu" 8 "SAB"
	label values crianca03 crianca03

	label variable crianca04 "11.4 Qual é o género de \${name_crianca}?"
	note crianca04: "11.4 Qual é o género de \${name_crianca}?"
	label define crianca04 1 "Masculino" 2 "Feminino"
	label values crianca04 crianca04

	label variable crianca05 "11.5 A(o) \${name_crianca} tem uma cédula pessoal ou um registo de nascimento?"
	note crianca05: "11.5 A(o) \${name_crianca} tem uma cédula pessoal ou um registo de nascimento?"
	label define crianca05 1 "Sim" 0 "Não" -888 "Não sabe"
	label values crianca05 crianca05

	label variable crianca07 "11.7 A que horas \${name_crianca} acordou ontem?"
	note crianca07: "11.7 A que horas \${name_crianca} acordou ontem?"

	label variable crianca08 "11.8 A que horas \${name_crianca} foi dormir ontem?"
	note crianca08: "11.8 A que horas \${name_crianca} foi dormir ontem?"

	label variable cuidador01 "12.1 Você é o cuidador principal de \${name_crianca}?"
	note cuidador01: "12.1 Você é o cuidador principal de \${name_crianca}?"
	label define cuidador01 1 "Sim" 0 "Não"
	label values cuidador01 cuidador01

	label variable cuidador02 "12.2 Qual é a relação do cuidador principal com \${name_crianca}?"
	note cuidador02: "12.2 Qual é a relação do cuidador principal com \${name_crianca}?"
	label define cuidador02 1 "Pai" 2 "Mãe" 3 "Irmã" 4 "Irmão" 5 "Primo" 6 "Prima" 7 "Tia" 8 "Tio" 9 "Avó" 10 "Avô" 11 "Madrasta" 12 "Padrasto" 13 "Outro familiar: ________" 14 "Outro não parente:_______"
	label values cuidador02 cuidador02

	label variable cuidador02_13 "12.2 Qual é a relação do cuidador principal com \${name_crianca}? OUTRO FAMILIAR"
	note cuidador02_13: "12.2 Qual é a relação do cuidador principal com \${name_crianca}? OUTRO FAMILIAR"

	label variable cuidador02_14 "12.2 Qual é a relação do cuidador principal com \${name_crianca}? OUTRO NÃO PARE"
	note cuidador02_14: "12.2 Qual é a relação do cuidador principal com \${name_crianca}? OUTRO NÃO PARENTE"

	label variable cuidador04 "12.4 A mãe biológica de \${name_crianca} vive no agregado familiar? (Selecione 2"
	note cuidador04: "12.4 A mãe biológica de \${name_crianca} vive no agregado familiar? (Selecione 2 se saiu PERMANENTEMENTE, por tempo indeterminado)"
	label define cuidador04 1 "Vive no agregado familiar" 2 "Não vive no agregado familiar" 3 "Falecida"
	label values cuidador04 cuidador04

	label variable cuidador05 "12.5 Desde que ano a mãe de \${name_crianca} não vive no agregado familiar?"
	note cuidador05: "12.5 Desde que ano a mãe de \${name_crianca} não vive no agregado familiar?"

	label variable cuidador06 "12.6 Em que ano a mãe de \${name_crianca} faleceu?"
	note cuidador06: "12.6 Em que ano a mãe de \${name_crianca} faleceu?"

	label variable cuidador07 "12.7 Com que frequência vê \${name_crianca} a sua mãe biológica?"
	note cuidador07: "12.7 Com que frequência vê \${name_crianca} a sua mãe biológica?"
	label define cuidador07 1 "Todos os dias" 2 "Várias vezes por semana" 3 "Algumas vezes por mês" 4 "Algumas vezes por ano" 5 "Uma vez por ano" 6 "Nunca"
	label values cuidador07 cuidador07

	label variable cuidador08 "12.8 Qual é a etnia do pai de \${name_crianca}?"
	note cuidador08: "12.8 Qual é a etnia do pai de \${name_crianca}?"
	label define cuidador08 1 "Sem etnia" 2 "Fula" 3 "Mandinga" 4 "Manjaco" 5 "Mancanha" 6 "Papel" 7 "Beafada" 8 "Felupe" 9 "Balanta" 10 "Balanta Mané" 11 "Nalu" 12 "Sussu" 13 "Saracolé" 14 "Bijagós" -777 "Outra"
	label values cuidador08 cuidador08

	label variable cuidador08_oth "12.8 Qual é a etnia do pai de \${name_crianca}? OUTRO"
	note cuidador08_oth: "12.8 Qual é a etnia do pai de \${name_crianca}? OUTRO"

	label variable cuidador09 "12.9 O pai de \${name_crianca} sabe ler e escrever?"
	note cuidador09: "12.9 O pai de \${name_crianca} sabe ler e escrever?"
	label define cuidador09 1 "Sim" 0 "Não"
	label values cuidador09 cuidador09

	label variable cuidador10 "12.10 Qual é o nível de ensino mais elevado que o pai de \${name_crianca} atingi"
	note cuidador10: "12.10 Qual é o nível de ensino mais elevado que o pai de \${name_crianca} atingiu?"
	label define cuidador10 1 "Pré-escolar ou nenhum" 2 "Ensino básico 1º ciclo" 3 "Ensino básico 2º ciclo" 4 "Ensino básico 3º ciclo" 5 "Ensino secundário 9º completo" 6 "Ensino secundário 10º completo" 7 "Ensino secundário 11º completo" 8 "Ensino secundário 12º completo" 9 "Ensino técnico incompleto" 10 "Ensino técnico completo" 11 "Bacharelato incompleto"
	label values cuidador10 cuidador10

	label variable cuidador11 "12.11 O pai de \${name_crianca} vive no agregado familiar? (Selecione 2 se saiu "
	note cuidador11: "12.11 O pai de \${name_crianca} vive no agregado familiar? (Selecione 2 se saiu PERMANENTEMENTE, por tempo indeterminado)"
	label define cuidador11 1 "Vive no agregado familiar" 2 "Não vive no agregado familiar" 3 "Falecida"
	label values cuidador11 cuidador11

	label variable cuidador12 "12.12 Desde que ano o pai de \${name_crianca} não vive no agregado familiar?"
	note cuidador12: "12.12 Desde que ano o pai de \${name_crianca} não vive no agregado familiar?"

	label variable cuidador13 "12.13 Em que ano o pai de \${name_crianca} faleceu?"
	note cuidador13: "12.13 Em que ano o pai de \${name_crianca} faleceu?"

	label variable cuidador14 "12.14 O pai de \${name_crianca} contribui financeiramente para os custos dela(e)"
	note cuidador14: "12.14 O pai de \${name_crianca} contribui financeiramente para os custos dela(e)?"
	label define cuidador14 1 "Sim, regularmente" 2 "Sim, mas de forma irregular" 3 "Não"
	label values cuidador14 cuidador14

	label variable cuidador14_2 "12.12.1 Com que frequência vê \${name_crianca} a su pai?"
	note cuidador14_2: "12.12.1 Com que frequência vê \${name_crianca} a su pai?"
	label define cuidador14_2 1 "Todos os dias" 2 "Várias vezes por semana" 3 "Algumas vezes por mês" 4 "Algumas vezes por ano" 5 "Uma vez por ano" 6 "Nunca"
	label values cuidador14_2 cuidador14_2

	label variable cuidador15 "12.15 Qual é a ocupação principal do pai de \${name_crianca}?"
	note cuidador15: "12.15 Qual é a ocupação principal do pai de \${name_crianca}?"

	label variable cuidador15_outra "Outro cuidador principal (especifique):"
	note cuidador15_outra: "Outro cuidador principal (especifique):"

	label variable cuidador16 "12.16 Na sua opinião, o pai de \${name_crianca} considera que a educação pré-esc"
	note cuidador16: "12.16 Na sua opinião, o pai de \${name_crianca} considera que a educação pré-escolar é importante para o desenvolvimento da criança?"
	label define cuidador16 1 "Sim, muito importante" 2 "Sim, mas não como essencial" 0 "Não" -888 "Não sei"
	label values cuidador16 cuidador16

	label variable servicios01 "13.1 Por que decidiu inscrever \${name_crianca} no jardim/pré-escola?"
	note servicios01: "13.1 Por que decidiu inscrever \${name_crianca} no jardim/pré-escola?"

	label variable servicios01_oth "13.1 Por que decidiu inscrever \${name_crianca} no jardim/pré-escola? OUTRO"
	note servicios01_oth: "13.1 Por que decidiu inscrever \${name_crianca} no jardim/pré-escola? OUTRO"

	label variable servicios02 "13.2 Conhece outras mães que também têm seus filhos neste jardim/pré-escola?"
	note servicios02: "13.2 Conhece outras mães que também têm seus filhos neste jardim/pré-escola?"
	label define servicios02 1 "Sim" 0 "Não"
	label values servicios02 servicios02

	label variable servicios03 "13.3 Conhecia-as antes de inscrever \${name_crianca} ou conheceu-as depois?"
	note servicios03: "13.3 Conhecia-as antes de inscrever \${name_crianca} ou conheceu-as depois?"
	label define servicios03 1 "Já as conhecia de antes." 2 "Conheci-as depois, quando meu/minha filho(a) começou a frequentar o jardim." 3 "Algumas sim, já as conhecia antes e outras depois."
	label values servicios03 servicios03

	label variable servicios04 "13.4 Quantas mães (que têm seus filhos neste jardim/pré-escola) conhece aproxima"
	note servicios04: "13.4 Quantas mães (que têm seus filhos neste jardim/pré-escola) conhece aproximadamente?"
	label define servicios04 1 "A 1 o 2" 2 "A 3 o 4" 3 "A 5 o mais"
	label values servicios04 servicios04

	label variable servicios05 "13.5 Em que medida o fato de outras mães da sua comunidade terem seus filhos num"
	note servicios05: "13.5 Em que medida o fato de outras mães da sua comunidade terem seus filhos num jardim influenciou sua decisão de matricular a(o) \${name_crianca} no jardim?"
	label define servicios05 1 "Influenciou muito na minha decisão" 2 "Influenciou um pouco na minha decisão" 3 "Não influenciou na minha decisão"
	label values servicios05 servicios05

	label variable servicios06 "13.6 'Na minha comunidade é bem visto (ou é normal) que as crianças frequentem o"
	note servicios06: "13.6 'Na minha comunidade é bem visto (ou é normal) que as crianças frequentem o jardim/pré-escolar.' Concorda?"
	label define servicios06 1 "Muito em desacordo" 2 "Em desacordo" 3 "De acordo" 4 "Muito de acordo"
	label values servicios06 servicios06

	label variable servicios07 "13.7 Pensando na semana passada, quais dias \${name_crianca} frequentou o jardim"
	note servicios07: "13.7 Pensando na semana passada, quais dias \${name_crianca} frequentou o jardim/pré-escola \${name_crianca}?"

	label variable servicios08 "13.8 Como \${name_crianca} normalmente vai e volta do jardim/pré-escola \${name_"
	note servicios08: "13.8 Como \${name_crianca} normalmente vai e volta do jardim/pré-escola \${name_jardim}?"

	label variable servicios08_oth "13.8 Como \${name_crianca} normalmente vai e volta do jardim/pré-escola \${name_"
	note servicios08_oth: "13.8 Como \${name_crianca} normalmente vai e volta do jardim/pré-escola \${name_jardim}? OUTRO"

	label variable servicios09 "13.9 Em que ano \${name_crianca} começou a frequentar o jardim/pré-escolar \${na"
	note servicios09: "13.9 Em que ano \${name_crianca} começou a frequentar o jardim/pré-escolar \${name_jardim} pela primeira vez?"

	label variable servicios10 "13.10 Em que mês \${name_crianca} começou a frequentar o jardim/pré-escolar \${n"
	note servicios10: "13.10 Em que mês \${name_crianca} começou a frequentar o jardim/pré-escolar \${name_jardim} pela primeira vez?"
	label define servicios10 1 "Janeiro" 2 "Fevereiro" 3 "Março" 4 "Abril" 5 "Maio" 6 "Junho" 7 "Julho" 8 "Agosto" 9 "Setembro" 10 "Outubro" 11 "Novembro" 12 "Dezembro" -888 "Não sabe"
	label values servicios10 servicios10

	label variable servicios11 "13.11 Desde essa data até agora, \${name_crianca} parou de frequentar o jardim/p"
	note servicios11: "13.11 Desde essa data até agora, \${name_crianca} parou de frequentar o jardim/pré -escola por mais de duas semanas consecutivas por motivos diferentes de férias?"
	label define servicios11 1 "Sim" 0 "Não"
	label values servicios11 servicios11

	label variable servicios12 "13.12 Por quantos meses no total \${name_crianca} deixou de frequentar o jardim/"
	note servicios12: "13.12 Por quantos meses no total \${name_crianca} deixou de frequentar o jardim/pré-escola?"

	label variable servicios13 "13.13 Por que \${name_crianca} parou de frequentar o jardim por mais de duas sem"
	note servicios13: "13.13 Por que \${name_crianca} parou de frequentar o jardim por mais de duas semanas consecutivas?"

	label variable servicios13_oth "13.13 Por que \${name_crianca} parou de frequentar o jardim por mais de duas sem"
	note servicios13_oth: "13.13 Por que \${name_crianca} parou de frequentar o jardim por mais de duas semanas consecutivas? OUTRO"

	label variable servicios14 "13.14 Quais fatores influenciam sua decisão de usar serviços de pré-escola/jardi"
	note servicios14: "13.14 Quais fatores influenciam sua decisão de usar serviços de pré-escola/jardim de infância? [Selecione tudo o que aplica]"

	label variable servicios14_oth "13.14 Quais fatores influenciam sua decisão de usar serviços de pré-escola/jardi"
	note servicios14_oth: "13.14 Quais fatores influenciam sua decisão de usar serviços de pré-escola/jardim de infância? OUTRO"

	label variable servicios15 "13.15 \${name_crianca} frequentou no passado algum outro serviço de pré-escola o"
	note servicios15: "13.15 \${name_crianca} frequentou no passado algum outro serviço de pré-escola ou jardim de infância diferente a \${name_jardim}?"
	label define servicios15 1 "Sim" 0 "Não"
	label values servicios15 servicios15

	label variable servicios16 "13.16 Por que razão você mudou \${name_crianca} daquele pré-escola/jardim para o"
	note servicios16: "13.16 Por que razão você mudou \${name_crianca} daquele pré-escola/jardim para o \${name_jardim}?"

	label variable servicios17 "13.17 Que diferenças observa entre crianças que frequentam o ensino pré-escolar "
	note servicios17: "13.17 Que diferenças observa entre crianças que frequentam o ensino pré-escolar e as que não frequentam? [Deixe que a pessoa responda e selecione todas as razões que mencionar]"

	label variable servicios17_oth "13.17 Que diferenças observa entre crianças que frequentam o ensino pré-escolar "
	note servicios17_oth: "13.17 Que diferenças observa entre crianças que frequentam o ensino pré-escolar e as que não frequentam? OUTRO"

	label variable servicios18 "13.18 As famílias desta comunidade pagam por serviços de cuidado e educação infa"
	note servicios18: "13.18 As famílias desta comunidade pagam por serviços de cuidado e educação infantil para crianças de 0 a 6 anos?"
	label define servicios18 1 "Sim, regularmente" 2 "Sim, mas poucas famílias conseguem pagar" 3 "Não, a maioria não pode pagar" 4 "Não, porque os serviços que existem são de graça" 5 "Não, porque não há serviços pré-escolares/jardim"
	label values servicios18 servicios18

	label variable servicios19 "13.19 Quais são as principais barreiras que dificultam o acesso ao ensino pré-es"
	note servicios19: "13.19 Quais são as principais barreiras que dificultam o acesso ao ensino pré-escolar nesta comunidade? [Deixe que a pessoa responda e selecione tudo o que se aplica]"

	label variable servicios19_oth "13.19 Quais são as principais barreiras que dificultam o acesso ao ensino pré-es"
	note servicios19_oth: "13.19 Quais são as principais barreiras que dificultam o acesso ao ensino pré-escolar nesta comunidade? OUTRO"

	label variable horario01 "14.1 Se o jardim \${name_jardim} oferecesse um serviço de horário estendido até "
	note horario01: "14.1 Se o jardim \${name_jardim} oferecesse um serviço de horário estendido até às 17:00 horas, você estaria interessada em usar esse serviço?"
	label define horario01 1 "Sim" 0 "Não"
	label values horario01 horario01

	label variable horario02 "14.2 E se este serviço fosse gratuito, você estaria interessada em utilizá-lo?"
	note horario02: "14.2 E se este serviço fosse gratuito, você estaria interessada em utilizá-lo?"
	label define horario02 1 "Sim" 0 "Não"
	label values horario02 horario02

	label variable horario03 "14.3 Por que você NÃO está interessada neste serviço?"
	note horario03: "14.3 Por que você NÃO está interessada neste serviço?"

	label variable horario04 "14.4 Suponha que você pode escolher um ou mais meses nos quais pode ter acesso a"
	note horario04: "14.4 Suponha que você pode escolher um ou mais meses nos quais pode ter acesso a este serviço (que o jardim esteja aberto até às 17 horas). Quais meses gostaria de ter acesso a este serviço?"

	label variable horario05 "14.5 Por que você escolheu esses meses?"
	note horario05: "14.5 Por que você escolheu esses meses?"

	label variable horario06 "14.6 Se você só pudesse ter acesso a este serviço por um mês, qual mês gostaria "
	note horario06: "14.6 Se você só pudesse ter acesso a este serviço por um mês, qual mês gostaria de ter acesso a esse serviço?"
	label define horario06 1 "Janeiro" 2 "Fevereiro" 3 "Março" 4 "Abril" 5 "Maio" 6 "Junho" 7 "Julho" 8 "Agosto" 9 "Setembro" 10 "Outubro" 11 "Novembro" 12 "Dezembro"
	label values horario06 horario06

	label variable horario07 "14.7 Quanto estaria disposto a pagar por mês por este serviço?"
	note horario07: "14.7 Quanto estaria disposto a pagar por mês por este serviço?"

	label variable horario09 "14.9 Quais são os principais fatores que determinariam sua decisão de NÃO querer"
	note horario09: "14.9 Quais são os principais fatores que determinariam sua decisão de NÃO querer usar este serviço?"

	label variable horario09_oth "14.9 Quais são os principais fatores que determinariam sua decisão de NÃO querer"
	note horario09_oth: "14.9 Quais são os principais fatores que determinariam sua decisão de NÃO querer usar este serviço? OUTRO"

	label variable ambiente01 "15.1 Quantos livros infantis e livros de desenho (ilustrados) tem para a(o) \${n"
	note ambiente01: "15.1 Quantos livros infantis e livros de desenho (ilustrados) tem para a(o) \${name_crianca}?"

	label variable ambiente03 "Ela(e) brinca com: 15.2.1 Brinquedos, tais como bonecas, carros ou outros brinqu"
	note ambiente03: "Ela(e) brinca com: 15.2.1 Brinquedos, tais como bonecas, carros ou outros brinquedos feitos em casa?"
	label define ambiente03 1 "Sim" 0 "Não" -888 "Não sei"
	label values ambiente03 ambiente03

	label variable ambiente05 "Ela(e) brinca com: 15.2.3 Objetos domésticos, tais como tigelas, bacias caçarola"
	note ambiente05: "Ela(e) brinca com: 15.2.3 Objetos domésticos, tais como tigelas, bacias caçarolas ou objetos encontrados na rua, tais como paus, pedras, conchas de animais ou folhas?"
	label define ambiente05 1 "Sim" 0 "Não" -888 "Não sei"
	label values ambiente05 ambiente05

	label variable ambiente07 "15.3.1 Durante a semana passada, quantos dias a(o) \${name_crianca} foi deixada("
	note ambiente07: "15.3.1 Durante a semana passada, quantos dias a(o) \${name_crianca} foi deixada(o) sozinha(o) por mais de uma hora?"

	label variable ambiente08 "15.3.2 Durante a semana passada, quantos dias a(o) \${name_crianca} foi deixado "
	note ambiente08: "15.3.2 Durante a semana passada, quantos dias a(o) \${name_crianca} foi deixado no cuidado de outra criança menor de 10 anos de idade por mais de uma hora?"

	label variable ambiente10 "15.4.1 Leu livros ou olhou para as imagens dos livros ilustrados com a(o) \${nam"
	note ambiente10: "15.4.1 Leu livros ou olhou para as imagens dos livros ilustrados com a(o) \${name_crianca}?"

	label variable ambiente11 "15.4.2 Contou histórias para \${name_crianca}?"
	note ambiente11: "15.4.2 Contou histórias para \${name_crianca}?"

	label variable ambiente12 "15.4.3 Cantou canções para ou com a(o) \${name_crianca}, incluindo as de ninar?"
	note ambiente12: "15.4.3 Cantou canções para ou com a(o) \${name_crianca}, incluindo as de ninar?"

	label variable ambiente13 "15.4.4 Levou \${name_crianca} para fora da casa?"
	note ambiente13: "15.4.4 Levou \${name_crianca} para fora da casa?"

	label variable ambiente14 "15.4.5 Brincou com a(o) \${name_crianca}?"
	note ambiente14: "15.4.5 Brincou com a(o) \${name_crianca}?"

	label variable ambiente15 "15.4.6 Nomeou, contou ou desenhou coisas para ou com a(o) \${name_crianca}?"
	note ambiente15: "15.4.6 Nomeou, contou ou desenhou coisas para ou com a(o) \${name_crianca}?"

	label variable disciplina02 "15.5.1 Retirou-lhe os privilégios, proibiu qualquer coisa de que o/a \${name_cri"
	note disciplina02: "15.5.1 Retirou-lhe os privilégios, proibiu qualquer coisa de que o/a \${name_crianca} gosta de fazer ou não lhe permitiu sair de casa."
	label define disciplina02 1 "Sim" 0 "Não"
	label values disciplina02 disciplina02

	label variable disciplina03 "15.5.2 Bateu-lhe no rabo com a mão nua, ou deu-lhe uma bofetada na cabeça ou pux"
	note disciplina03: "15.5.2 Bateu-lhe no rabo com a mão nua, ou deu-lhe uma bofetada na cabeça ou puxou-lhe as orelhas"
	label define disciplina03 1 "Sim" 0 "Não"
	label values disciplina03 disciplina03

	label variable disciplina04 "15.5.3 Explicou o /a \${name_crianca} porque é que o seu comportamento não é cor"
	note disciplina04: "15.5.3 Explicou o /a \${name_crianca} porque é que o seu comportamento não é correto."
	label define disciplina04 1 "Sim" 0 "Não"
	label values disciplina04 disciplina04

	label variable disciplina05 "15.5.4 Agitou-a de forma forte."
	note disciplina05: "15.5.4 Agitou-a de forma forte."
	label define disciplina05 1 "Sim" 0 "Não"
	label values disciplina05 disciplina05

	label variable disciplina06 "15.5.5 Gritou/berrou com ele/ela."
	note disciplina06: "15.5.5 Gritou/berrou com ele/ela."
	label define disciplina06 1 "Sim" 0 "Não"
	label values disciplina06 disciplina06

	label variable disciplina07 "15.5.6 Deu-lhe alguma coisa para fazer."
	note disciplina07: "15.5.6 Deu-lhe alguma coisa para fazer."
	label define disciplina07 1 "Sim" 0 "Não"
	label values disciplina07 disciplina07

	label variable disciplina08 "15.5.7 Bateu-lhe no rabo ou outra parte do corpo com algo como um cinto, escova,"
	note disciplina08: "15.5.7 Bateu-lhe no rabo ou outra parte do corpo com algo como um cinto, escova, vara, pau outro objeto duro"
	label define disciplina08 1 "Sim" 0 "Não"
	label values disciplina08 disciplina08

	label variable saude01 "16.1 Existe um cartão/caderneta de vacinas ou um outro documento de um técnico d"
	note saude01: "16.1 Existe um cartão/caderneta de vacinas ou um outro documento de um técnico de saúde privado onde estão registadas todas as vacinas do \${name_crianca}?"
	label define saude01 1 "Sim, somente um Cartão/Caderneta" 2 "Sim, somente um outro documento" 3 "Sim, cartão/caderneta e outro documento" 0 "Não, nem tem Cartão/Caderneta e outro documento"
	label values saude01 saude01

	label variable saude02 "16.2 Durante os últimos 6 meses, a criança recebeu um medicamento/plantas antipa"
	note saude02: "16.2 Durante os últimos 6 meses, a criança recebeu um medicamento/plantas antiparasitárias?"
	label define saude02 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude02 saude02

	label variable saude03 "16.3.1 Nos últimos 15 dias \${name_crianca} teve diarreia?"
	note saude03: "16.3.1 Nos últimos 15 dias \${name_crianca} teve diarreia?"
	label define saude03 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude03 saude03

	label variable saude04 "16.3.2 Nos últimos 15 dias, quantos dias é que \${name_crianca} esteve doente co"
	note saude04: "16.3.2 Nos últimos 15 dias, quantos dias é que \${name_crianca} esteve doente com diarreia?"

	label variable saude05 "16.3.3 Procurou qualquer conselho ou tratamento contra a diarreia?"
	note saude05: "16.3.3 Procurou qualquer conselho ou tratamento contra a diarreia?"
	label define saude05 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude05 saude05

	label variable saude06 "16.3.4 Onde procurou conselho ou tratamento? [Insista:] Algum outro lugar? [Circ"
	note saude06: "16.3.4 Onde procurou conselho ou tratamento? [Insista:] Algum outro lugar? [Circule todos os lugares mencionados, mas não sugira respostas]"

	label variable saude07 "16.4.1 Nos últimos 15 dias \${name_crianca} teve tosse, constipação ou gripe?"
	note saude07: "16.4.1 Nos últimos 15 dias \${name_crianca} teve tosse, constipação ou gripe?"
	label define saude07 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude07 saude07

	label variable saude08 "16.4.2 Nos últimos 15 dias, quantos dias é que \${name_crianca} esteve doente co"
	note saude08: "16.4.2 Nos últimos 15 dias, quantos dias é que \${name_crianca} esteve doente com tosse, constipação ou gripe?"

	label variable saude09 "16.4.3 Procurou qualquer conselho ou tratamento contra essa tosse, constipação o"
	note saude09: "16.4.3 Procurou qualquer conselho ou tratamento contra essa tosse, constipação ou gripe?"
	label define saude09 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude09 saude09

	label variable saude10 "16.4.4 Onde procurou conselho ou tratamento? [Insista:] Algum outro lugar? [Circ"
	note saude10: "16.4.4 Onde procurou conselho ou tratamento? [Insista:] Algum outro lugar? [Circule todos os lugares mencionados, mas não sugira respostas]"

	label variable saude11 "16.5.1 Nos últimos 15 dias \${name_crianca} teve alguma outra doença ou queixa?"
	note saude11: "16.5.1 Nos últimos 15 dias \${name_crianca} teve alguma outra doença ou queixa?"
	label define saude11 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude11 saude11

	label variable saude12 "16.5.2 Qual?"
	note saude12: "16.5.2 Qual?"

	label variable saude14 "16.6.1 Na semana passada, de segunda a sexta-feira, a \${name_crianca} tomou o P"
	note saude14: "16.6.1 Na semana passada, de segunda a sexta-feira, a \${name_crianca} tomou o PEQUENO-ALMOCO em casa?"
	label define saude14 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude14 saude14

	label variable saude15 "16.6.2 Por que não? [Leia as opções]"
	note saude15: "16.6.2 Por que não? [Leia as opções]"

	label variable saude15_oth "'16.6.2 Por que não? OUTRO"
	note saude15_oth: "'16.6.2 Por que não? OUTRO"

	label variable saude16 "16.7.1 Na semana passada, de segunda a sexta-feira, a \${name_crianca} tomou o L"
	note saude16: "16.7.1 Na semana passada, de segunda a sexta-feira, a \${name_crianca} tomou o LANCHE DA MANHÃ em casa?"
	label define saude16 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude16 saude16

	label variable saude17 "16.7.2 Por que não? [Leia as opções]"
	note saude17: "16.7.2 Por que não? [Leia as opções]"

	label variable saude17_oth "16.7.2 Por que não? OUTRO"
	note saude17_oth: "16.7.2 Por que não? OUTRO"

	label variable saude18 "16.8.1 Na semana passada, de segunda a sexta-feira, a \${name_crianca} tomou ALM"
	note saude18: "16.8.1 Na semana passada, de segunda a sexta-feira, a \${name_crianca} tomou ALMOÇOU em casa?"
	label define saude18 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude18 saude18

	label variable saude19 "16.8.2 Por que não? [Leia as opções]"
	note saude19: "16.8.2 Por que não? [Leia as opções]"

	label variable saude19_oth "16.8.2 Por que não? OUTRO"
	note saude19_oth: "16.8.2 Por que não? OUTRO"

	label variable saude20 "16.9.1 Na semana passada, de segunda a sexta-feira, a \${name_crianca} tomou o L"
	note saude20: "16.9.1 Na semana passada, de segunda a sexta-feira, a \${name_crianca} tomou o LANCHE DA TARDE em casa?"
	label define saude20 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude20 saude20

	label variable saude21 "16.9.2 Por que não? [Leia as opções]"
	note saude21: "16.9.2 Por que não? [Leia as opções]"

	label variable saude21_oth "16.9.2 Por que não? OUTRO"
	note saude21_oth: "16.9.2 Por que não? OUTRO"

	label variable saude22 "16.10.1 Na semana passada, de segunda a sexta-feira, a \${name_crianca} JANTOU e"
	note saude22: "16.10.1 Na semana passada, de segunda a sexta-feira, a \${name_crianca} JANTOU em casa?"
	label define saude22 1 "Sim" 0 "Não" -888 "Não sabe"
	label values saude22 saude22

	label variable saude23 "16.10.2 Por que não? [Leia as opções]"
	note saude23: "16.10.2 Por que não? [Leia as opções]"

	label variable saude23_oth "16.10.2 Por que não? OUTRO"
	note saude23_oth: "16.10.2 Por que não? OUTRO"

	label variable desenvolvimiento_a02 "17.1.1 Se você apontar para um objeto (ex: copo ou animal), a criança sabe nomeá"
	note desenvolvimiento_a02: "17.1.1 Se você apontar para um objeto (ex: copo ou animal), a criança sabe nomeá-los corretamente?"
	label define desenvolvimiento_a02 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a02 desenvolvimiento_a02

	label variable desenvolvimiento_a03 "17.1.2 A criança consegue falar mais de 10 palavras separadas (ex: nomes como 'm"
	note desenvolvimiento_a03: "17.1.2 A criança consegue falar mais de 10 palavras separadas (ex: nomes como 'mama' ou objetos como 'bola')?"
	label define desenvolvimiento_a03 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a03 desenvolvimiento_a03

	label variable desenvolvimiento_a04 "17.1.3 A criança consegue cantar uma música curta (musiquinha) ou repetir frases"
	note desenvolvimiento_a04: "17.1.3 A criança consegue cantar uma música curta (musiquinha) ou repetir frases com rimas (ex: poema) sozinha?"
	label define desenvolvimiento_a04 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a04 desenvolvimiento_a04

	label variable desenvolvimiento_a05 "17.1.4 A criança consegue pular com os dois pés deixando o chão?"
	note desenvolvimiento_a05: "17.1.4 A criança consegue pular com os dois pés deixando o chão?"
	label define desenvolvimiento_a05 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a05 desenvolvimiento_a05

	label variable desenvolvimiento_a06 "17.1.5 A criança consegue falar utilizando frases de 3 ou 4 palavras juntas (ex:"
	note desenvolvimiento_a06: "17.1.5 A criança consegue falar utilizando frases de 3 ou 4 palavras juntas (ex: 'Eu quero água' ou 'A casa é grande')?"
	label define desenvolvimiento_a06 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a06 desenvolvimiento_a06

	label variable desenvolvimiento_a07 "17.1.6 A criança consegue fazer perguntas corretamente utilizando alguma das pal"
	note desenvolvimiento_a07: "17.1.6 A criança consegue fazer perguntas corretamente utilizando alguma das palavras 'O que' 'Quem' 'Onde' 'Quando'?"
	label define desenvolvimiento_a07 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a07 desenvolvimiento_a07

	label variable desenvolvimiento_a08 "17.1.7 A criança usa corretamente alguma das palavras 'eu', 'tu', 'ele' ou 'ela'"
	note desenvolvimiento_a08: "17.1.7 A criança usa corretamente alguma das palavras 'eu', 'tu', 'ele' ou 'ela' (ex: 'Eu vou ´áloja' ou 'Ele come arroz')?"
	label define desenvolvimiento_a08 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a08 desenvolvimiento_a08

	label variable desenvolvimiento_a09 "17.1.8 A criança pergunta por pessoas familiares que não sejam os pais, quando e"
	note desenvolvimiento_a09: "17.1.8 A criança pergunta por pessoas familiares que não sejam os pais, quando eles não estão presentes (ex: 'Onde está o vizinho?')"
	label define desenvolvimiento_a09 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a09 desenvolvimiento_a09

	label variable desenvolvimiento_a10 "17.1.9 A criança consegue contar até cinco objetos (ex: dedos, pessoas)?"
	note desenvolvimiento_a10: "17.1.9 A criança consegue contar até cinco objetos (ex: dedos, pessoas)?"
	label define desenvolvimiento_a10 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a10 desenvolvimiento_a10

	label variable desenvolvimiento_a11 "17.1.10 A criança consegue identificar pelo menos uma cor (ex: vermelho, azul, a"
	note desenvolvimiento_a11: "17.1.10 A criança consegue identificar pelo menos uma cor (ex: vermelho, azul, amarelo)?"
	label define desenvolvimiento_a11 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a11 desenvolvimiento_a11

	label variable desenvolvimiento_a12 "17.1.11 A criança com frequência dá pontapé, morde ou bate em outras crianças ou"
	note desenvolvimiento_a12: "17.1.11 A criança com frequência dá pontapé, morde ou bate em outras crianças ou adultos?"
	label define desenvolvimiento_a12 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a12 desenvolvimiento_a12

	label variable desenvolvimiento_a13 "17.1.12 Se você mostrar à criança dois objetos ou pessoas de diferentes tamanhos"
	note desenvolvimiento_a13: "17.1.12 Se você mostrar à criança dois objetos ou pessoas de diferentes tamanhos, ela consegue dizer qual é o objeto pequeno e qual é o grande?"
	label define desenvolvimiento_a13 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a13 desenvolvimiento_a13

	label variable desenvolvimiento_a14 "17.1.13 A criança fica isolada/reservada ou envergonhada em situações novas?"
	note desenvolvimiento_a14: "17.1.13 A criança fica isolada/reservada ou envergonhada em situações novas?"
	label define desenvolvimiento_a14 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a14 desenvolvimiento_a14

	label variable desenvolvimiento_a15 "17.1.14 Se você apontar para um objeto, a criança consegue usar corretamente as "
	note desenvolvimiento_a15: "17.1.14 Se você apontar para um objeto, a criança consegue usar corretamente as palavras 'em cima', 'dentro' ou 'embaixo' para descrever onde ele está (ex: 'O copo está em cima da mesa' em vez de 'O copo está dentro da mesa')?"
	label define desenvolvimiento_a15 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a15 desenvolvimiento_a15

	label variable desenvolvimiento_a16 "17.1.15 A criança faz perguntas 'porquês' (ex: 'Por que você é alto?')?"
	note desenvolvimiento_a16: "17.1.15 A criança faz perguntas 'porquês' (ex: 'Por que você é alto?')?"
	label define desenvolvimiento_a16 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a16 desenvolvimiento_a16

	label variable desenvolvimiento_a17 "17.1.16 Se você pedir para a criança te dar três objetos (ex: pedra, feijões), a"
	note desenvolvimiento_a17: "17.1.16 Se você pedir para a criança te dar três objetos (ex: pedra, feijões), a criança entrega para você a quantidade correta?"
	label define desenvolvimiento_a17 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a17 desenvolvimiento_a17

	label variable desenvolvimiento_a18 "17.1.17 A criança consegue explicar com palavras para que servem objetos comuns "
	note desenvolvimiento_a18: "17.1.17 A criança consegue explicar com palavras para que servem objetos comuns como copo e cadeira?"
	label define desenvolvimiento_a18 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a18 desenvolvimiento_a18

	label variable desenvolvimiento_a19 "17.1.18 A criança consegue vestir roupas ou algumas peças do vestuário |sozinha "
	note desenvolvimiento_a19: "17.1.18 A criança consegue vestir roupas ou algumas peças do vestuário |sozinha (ex: vestir as calças ou colocar a blusa sem ajuda)?"
	label define desenvolvimiento_a19 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a19 desenvolvimiento_a19

	label variable desenvolvimiento_a20 "17.1.19 A criança sabe dizer o que os outros gostam e não gostam (ex: 'Mamãe não"
	note desenvolvimiento_a20: "17.1.19 A criança sabe dizer o que os outros gostam e não gostam (ex: 'Mamãe não gosta de frutas' 'Papai gosta de futebol')?"
	label define desenvolvimiento_a20 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a20 desenvolvimiento_a20

	label variable desenvolvimiento_a21 "17.1.20 A criança consegue falar sobre coisas que aconteceram no passado utiliza"
	note desenvolvimiento_a21: "17.1.20 A criança consegue falar sobre coisas que aconteceram no passado utilizando a linguagem correta (ex: 'Ontem eu brinquei com os meus amigos' ou 'Na semana passada ela foi ao supermercado')?"
	label define desenvolvimiento_a21 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_a21 desenvolvimiento_a21

	label variable desenvolvimiento_b02 "18.1.1 A criança consegue falar mais de 10 palavras separadas (ex: nomes como 'm"
	note desenvolvimiento_b02: "18.1.1 A criança consegue falar mais de 10 palavras separadas (ex: nomes como 'mamã' ou objetos como 'bola')?"
	label define desenvolvimiento_b02 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b02 desenvolvimiento_b02

	label variable desenvolvimiento_b03 "18.1.2 A criança consegue pular com os dois pés deixando o chão?"
	note desenvolvimiento_b03: "18.1.2 A criança consegue pular com os dois pés deixando o chão?"
	label define desenvolvimiento_b03 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b03 desenvolvimiento_b03

	label variable desenvolvimiento_b04 "18.1.3 A criança consegue falar utilizando frases de 3 ou 4 palavras juntas (ex:"
	note desenvolvimiento_b04: "18.1.3 A criança consegue falar utilizando frases de 3 ou 4 palavras juntas (ex: 'Eu quero água' ou 'A casa é grande')?"
	label define desenvolvimiento_b04 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b04 desenvolvimiento_b04

	label variable desenvolvimiento_b05 "18.1.4 A criança consegue cantar uma música curta (musiquinhas) ou repetir frase"
	note desenvolvimiento_b05: "18.1.4 A criança consegue cantar uma música curta (musiquinhas) ou repetir frases com rimas (ex: poema) sozinha?"
	label define desenvolvimiento_b05 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b05 desenvolvimiento_b05

	label variable desenvolvimiento_b06 "18.1.5 Criança consegue fazer perguntas corretamente utilizando alguma das palav"
	note desenvolvimiento_b06: "18.1.5 Criança consegue fazer perguntas corretamente utilizando alguma das palavras 'O que' 'Quem' 'Onde' 'Quando'?"
	label define desenvolvimiento_b06 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b06 desenvolvimiento_b06

	label variable desenvolvimiento_b07 "18.1.6 A criança pergunta por pessoas familiares, que não sejam os pais, quando "
	note desenvolvimiento_b07: "18.1.6 A criança pergunta por pessoas familiares, que não sejam os pais, quando eles não estão presentes (ex: 'Onde está o vizinho?')?"
	label define desenvolvimiento_b07 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b07 desenvolvimiento_b07

	label variable desenvolvimiento_b08 "18.1.7 A criança usa corretamente alguma das palavras 'eu', 'tu' 'ele'ou 'ela' ("
	note desenvolvimiento_b08: "18.1.7 A criança usa corretamente alguma das palavras 'eu', 'tu' 'ele'ou 'ela' (ex: 'Eu vou na loja', ou 'Ele come arroz?')?"
	label define desenvolvimiento_b08 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b08 desenvolvimiento_b08

	label variable desenvolvimiento_b09 "18.1.8 A criança consegue contar até cinco objetos (ex: dedos, pessoas)?"
	note desenvolvimiento_b09: "18.1.8 A criança consegue contar até cinco objetos (ex: dedos, pessoas)?"
	label define desenvolvimiento_b09 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b09 desenvolvimiento_b09

	label variable desenvolvimiento_b10 "18.1.9 A criança consegue identificar pelo menos uma cor (ex: vermelho, azul ou "
	note desenvolvimiento_b10: "18.1.9 A criança consegue identificar pelo menos uma cor (ex: vermelho, azul ou amarelo)?"
	label define desenvolvimiento_b10 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b10 desenvolvimiento_b10

	label variable desenvolvimiento_b11 "18.1.10 Se você mostrar à criança dois objetos ou pessoas de diferentes tamanhos"
	note desenvolvimiento_b11: "18.1.10 Se você mostrar à criança dois objetos ou pessoas de diferentes tamanhos, ela consegue dizer qual é o objeto pequeno e qual é o grande?"
	label define desenvolvimiento_b11 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b11 desenvolvimiento_b11

	label variable desenvolvimiento_b12 "18.1.11 Se você apontar para um objeto, a criança consegue usar corretamente as "
	note desenvolvimiento_b12: "18.1.11 Se você apontar para um objeto, a criança consegue usar corretamente as palavras 'em cima', 'dentro' ou 'embaixo' para descrever onde ele está (ex: O copo está em cima da mesa' em vez de'O copo está dentro da mesa')?"
	label define desenvolvimiento_b12 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b12 desenvolvimiento_b12

	label variable desenvolvimiento_b13 "18.1.12 A criança consegue explicar com palavras para que servem objetos comuns "
	note desenvolvimiento_b13: "18.1.12 A criança consegue explicar com palavras para que servem objetos comuns como copo e cadeira?"
	label define desenvolvimiento_b13 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b13 desenvolvimiento_b13

	label variable desenvolvimiento_b14 "18.1.13 A criança consegue vestir roupas ou algumas peças do vestuário sozinha ("
	note desenvolvimiento_b14: "18.1.13 A criança consegue vestir roupas ou algumas peças do vestuário sozinha (ex: vestir as calças ou colocar a blusa sem ajuda)?"
	label define desenvolvimiento_b14 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b14 desenvolvimiento_b14

	label variable desenvolvimiento_b15 "18.1.14 A criança faz perguntas 'porquês'? (ex:'Por que você é alto?')"
	note desenvolvimiento_b15: "18.1.14 A criança faz perguntas 'porquês'? (ex:'Por que você é alto?')"
	label define desenvolvimiento_b15 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b15 desenvolvimiento_b15

	label variable desenvolvimiento_b16 "18.1.15 Se você pedir para a criança te dar três objetos (ex: pedra, feijões), a"
	note desenvolvimiento_b16: "18.1.15 Se você pedir para a criança te dar três objetos (ex: pedra, feijões), a criança entrega para você a quantidade correta?"
	label define desenvolvimiento_b16 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b16 desenvolvimiento_b16

	label variable desenvolvimiento_b17 "18.1.16 A criança com frequência dá pontapé, morde ou bate em outras crianças ou"
	note desenvolvimiento_b17: "18.1.16 A criança com frequência dá pontapé, morde ou bate em outras crianças ou adultos?"
	label define desenvolvimiento_b17 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b17 desenvolvimiento_b17

	label variable desenvolvimiento_b18 "18.1.17 A criança fica isolada/reservada ou envergonhada em situações novas?"
	note desenvolvimiento_b18: "18.1.17 A criança fica isolada/reservada ou envergonhada em situações novas?"
	label define desenvolvimiento_b18 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b18 desenvolvimiento_b18

	label variable desenvolvimiento_b19 "18.1.18 A criança age impulsivamente ou sem pensar com frequência (ex:corre para"
	note desenvolvimiento_b19: "18.1.18 A criança age impulsivamente ou sem pensar com frequência (ex:corre para a rua sem olhar)?"
	label define desenvolvimiento_b19 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b19 desenvolvimiento_b19

	label variable desenvolvimiento_b20 "18.1.19 A criança sabe dizer o que os outros gostam e não gostam (ex:'A Mamã não"
	note desenvolvimiento_b20: "18.1.19 A criança sabe dizer o que os outros gostam e não gostam (ex:'A Mamã não gosta de frutas' 'O Papá gosta de futebol')?"
	label define desenvolvimiento_b20 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b20 desenvolvimiento_b20

	label variable desenvolvimiento_b21 "18.1.20 A criança consegue falar sobre coisas que aconteceram no passado utiliza"
	note desenvolvimiento_b21: "18.1.20 A criança consegue falar sobre coisas que aconteceram no passado utilizando a linguagem correta (ex: 'Ontem eu brinquei com os meus amigos' ou 'Na semana passada ela foi ao supermercado')?"
	label define desenvolvimiento_b21 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_b21 desenvolvimiento_b21

	label variable desenvolvimiento_c02 "19.1.1 \${name_crianca} sabe dizer pelo menos, dez letras?"
	note desenvolvimiento_c02: "19.1.1 \${name_crianca} sabe dizer pelo menos, dez letras?"
	label define desenvolvimiento_c02 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c02 desenvolvimiento_c02

	label variable desenvolvimiento_c03 "19.1.2 \${name_crianca} consegue ler quatro palavras simples?"
	note desenvolvimiento_c03: "19.1.2 \${name_crianca} consegue ler quatro palavras simples?"
	label define desenvolvimiento_c03 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c03 desenvolvimiento_c03

	label variable desenvolvimiento_c04 "19.1.3 \${name_crianca} consegue seguir o texto em uma direção correta da esquer"
	note desenvolvimiento_c04: "19.1.3 \${name_crianca} consegue seguir o texto em uma direção correta da esquerda para a direita e de cima para baixo, mesmo que não saiba ler?"
	label define desenvolvimiento_c04 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c04 desenvolvimiento_c04

	label variable desenvolvimiento_c05 "19.1.4 \${name_crianca} consegue escrever pelo menos três letras?"
	note desenvolvimiento_c05: "19.1.4 \${name_crianca} consegue escrever pelo menos três letras?"
	label define desenvolvimiento_c05 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c05 desenvolvimiento_c05

	label variable desenvolvimiento_c06 "19.1.5 \${name_crianca} sabe escrever uma palavra simples, além do seu nome?"
	note desenvolvimiento_c06: "19.1.5 \${name_crianca} sabe escrever uma palavra simples, além do seu nome?"
	label define desenvolvimiento_c06 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c06 desenvolvimiento_c06

	label variable desenvolvimiento_c07 "19.1.6 \${name_crianca} sabe contar de 1 a 10?"
	note desenvolvimiento_c07: "19.1.6 \${name_crianca} sabe contar de 1 a 10?"
	label define desenvolvimiento_c07 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c07 desenvolvimiento_c07

	label variable desenvolvimiento_c08 "19.1.7 \${name_crianca} sabe contar de 1 a 20?"
	note desenvolvimiento_c08: "19.1.7 \${name_crianca} sabe contar de 1 a 20?"
	label define desenvolvimiento_c08 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c08 desenvolvimiento_c08

	label variable desenvolvimiento_c09 "19.1.8 \${name_crianca} sabe a diferença entre alto e baixo usando dois exemplos"
	note desenvolvimiento_c09: "19.1.8 \${name_crianca} sabe a diferença entre alto e baixo usando dois exemplos de animais como, por exemplo, que uma vaca é mais alto que um gato?"
	label define desenvolvimiento_c09 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c09 desenvolvimiento_c09

	label variable desenvolvimiento_c10 "19.1.9 \${name_crianca} sabe a diferença entre pesado e leve usando dois exemplo"
	note desenvolvimiento_c10: "19.1.9 \${name_crianca} sabe a diferença entre pesado e leve usando dois exemplos de animais como, por exemplo, que uma vaca é mais pesado que uma cabra?"
	label define desenvolvimiento_c10 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c10 desenvolvimiento_c10

	label variable desenvolvimiento_c11 "19.1.10 \${name_crianca} sabe a diferença entre ontem, hoje e amanhã?"
	note desenvolvimiento_c11: "19.1.10 \${name_crianca} sabe a diferença entre ontem, hoje e amanhã?"
	label define desenvolvimiento_c11 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c11 desenvolvimiento_c11

	label variable desenvolvimiento_c12 "19.1.11 \${name_crianca} sabe que um número de um algarismo é maior do que outro"
	note desenvolvimiento_c12: "19.1.11 \${name_crianca} sabe que um número de um algarismo é maior do que outro número de um algarismo, por exemplo, que 4 é maior que 2?"
	label define desenvolvimiento_c12 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c12 desenvolvimiento_c12

	label variable desenvolvimiento_c13 "19.1. 2 \${name_crianca} consegue presta atenção quando faz uma atividade?"
	note desenvolvimiento_c13: "19.1. 2 \${name_crianca} consegue presta atenção quando faz uma atividade?"
	label define desenvolvimiento_c13 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c13 desenvolvimiento_c13

	label variable desenvolvimiento_c14 "19.1.13 Quando lhe pedem para fazer várias coisas, o(a) (nome) lembra-se de toda"
	note desenvolvimiento_c14: "19.1.13 Quando lhe pedem para fazer várias coisas, o(a) (nome) lembra-se de todas as instruções?"
	label define desenvolvimiento_c14 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c14 desenvolvimiento_c14

	label variable desenvolvimiento_c15 "19.1.14 \${name_crianca} é capaz de planear com antecedência?"
	note desenvolvimiento_c15: "19.1.14 \${name_crianca} é capaz de planear com antecedência?"
	label define desenvolvimiento_c15 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c15 desenvolvimiento_c15

	label variable desenvolvimiento_c16 "19.1.15 \${name_crianca} para uma atividade quando lhe é dito para fazer?"
	note desenvolvimiento_c16: "19.1.15 \${name_crianca} para uma atividade quando lhe é dito para fazer?"
	label define desenvolvimiento_c16 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c16 desenvolvimiento_c16

	label variable desenvolvimiento_c17 "19.1.16 \${name_crianca} continua a trabalhar numa coisa até acabar?"
	note desenvolvimiento_c17: "19.1.16 \${name_crianca} continua a trabalhar numa coisa até acabar?"
	label define desenvolvimiento_c17 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c17 desenvolvimiento_c17

	label variable desenvolvimiento_c18 "19.1.17 \${name_crianca} dá-se bem com outras crianças com quem brinca?"
	note desenvolvimiento_c18: "19.1.17 \${name_crianca} dá-se bem com outras crianças com quem brinca?"
	label define desenvolvimiento_c18 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c18 desenvolvimiento_c18

	label variable desenvolvimiento_c19 "19.1.18 \${name_crianca} adapta-se facilmente às transições como, por exemplo, a"
	note desenvolvimiento_c19: "19.1.18 \${name_crianca} adapta-se facilmente às transições como, por exemplo, a uma mudança na alimentação ou à remoção de um brinquedo?"
	label define desenvolvimiento_c19 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c19 desenvolvimiento_c19

	label variable desenvolvimiento_c20 "19.1.19 \${name_crianca} aceita uma responsabilidade pelos seus actos?"
	note desenvolvimiento_c20: "19.1.19 \${name_crianca} aceita uma responsabilidade pelos seus actos?"
	label define desenvolvimiento_c20 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c20 desenvolvimiento_c20

	label variable desenvolvimiento_c21 "19.1.20 \${name_crianca} acalma-se após períodos de atividade exitante?"
	note desenvolvimiento_c21: "19.1.20 \${name_crianca} acalma-se após períodos de atividade exitante?"
	label define desenvolvimiento_c21 1 "Sim" 0 "Não" -888 "Não sei"
	label values desenvolvimiento_c21 desenvolvimiento_c21

	label variable comments "\${enum_name}, por favor, escreva todos os comentários que você possa ter sobre "
	note comments: "\${enum_name}, por favor, escreva todos os comentários que você possa ter sobre a inquerito."



	capture {
		foreach rgvar of varlist eligi10_* {
			label variable `rgvar' "1.10 Nome completo da criança \${index_eligi10}"
			note `rgvar': "1.10 Nome completo da criança \${index_eligi10}"
		}
	}

	capture {
		foreach rgvar of varlist agre_fam11_* {
			label variable `rgvar' "4.16 Qual é o nome e apelido completo do filho \${posicion_miembro}?"
			note `rgvar': "4.16 Qual é o nome e apelido completo do filho \${posicion_miembro}?"
		}
	}

	capture {
		foreach rgvar of varlist agre_fam12_* {
			label variable `rgvar' "4.17 Qual é a idade de \${agre_fam11}?"
			note `rgvar': "4.17 Qual é a idade de \${agre_fam11}?"
		}
	}

	capture {
		foreach rgvar of varlist agre_fam12_1_* {
			label variable `rgvar' "4.17.1 Qual é o sexo de \${agre_fam11} ?"
			note `rgvar': "4.17.1 Qual é o sexo de \${agre_fam11} ?"
			label define `rgvar' 1 "Masculino" 2 "Feminino"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist agre_fam13_* {
			label variable `rgvar' "4.18 Qual é a relação entre a(o) \${agre_fam11} e a(o) chefe do agregado familia"
			note `rgvar': "4.18 Qual é a relação entre a(o) \${agre_fam11} e a(o) chefe do agregado familiar?"
			label define `rgvar' 1 "Chefe Do Agregado" 2 "Cônjuge/Parceiro" 3 "Filho/Filha" 4 "Genro/Nora" 5 "Neto Ou Bisneto" 6 "Mãe /Pai" 7 "Sogro/Sogra" 8 "Irmão / Irmã" 9 "Cunhado /Cunhada" 10 "Tio / Tia" 11 "Sobrinho / Sobrinha" 12 "Doméstica (Vive No Agregado)" 13 "Criança Adotada/ Confiada/Enteado (A)" 14 "Outro (Parente)" 15 "Outro (Sem Grau De Parentesco)"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist tempo04_* {
			label variable `rgvar' "7.4 Das \${hora_ini}h até \${hora_fin}h, qual foi a principal atividade que real"
			note `rgvar': "7.4 Das \${hora_ini}h até \${hora_fin}h, qual foi a principal atividade que realizou?"
			label define `rgvar' 1 "Dormir" 2 "Realizar trabalho remunerado fora de casa com salário diário ou regular" 3 "Realizar trabalho remunerado fora de casa por conta própria" 4 "Realizar trabalho remunerado na parcela familiar (cultivos próprios)" 5 "Realizar trabalho não remunerado na parcela familiar (cultivos próprios)" 6 "Realizar trabalho não remunerado fora de casa" 7 "Realizar tarefas domésticas não remuneradas para seu próprio lar" 8 "Cuidar ativamente de crianças e acrescentaria" 9 "Cuidar ativamente de outro ente familiar" 10 "Descanso, lazer" 11 "Estudar" -777 "Outro:"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist tempo04_oth_* {
			label variable `rgvar' "7.4 Das \${hora_ini}h até \${hora_fin}h, qual foi a principal atividade que real"
			note `rgvar': "7.4 Das \${hora_ini}h até \${hora_fin}h, qual foi a principal atividade que realizou?: OUTRO"
		}
	}

	capture {
		foreach rgvar of varlist tempo05_* {
			label variable `rgvar' "7.5 Das \${hora_ini}h até \${hora_fin}h, você cuidou passivamente de uma criança"
			note `rgvar': "7.5 Das \${hora_ini}h até \${hora_fin}h, você cuidou passivamente de uma criança?"
			label define `rgvar' 1 "Sim" 0 "Não"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist crianca09_* {
			label variable `rgvar' "11.9 Das \${temporary_hora_cuidado}h até \${temporary_hora_cuidado2}h, quem foi "
			note `rgvar': "11.9 Das \${temporary_hora_cuidado}h até \${temporary_hora_cuidado2}h, quem foi a principal ou principais pessoa(s) que cuidou (aram) de \${name_crianca}? [Selecione até 3 pessoas]"
		}
	}

	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

