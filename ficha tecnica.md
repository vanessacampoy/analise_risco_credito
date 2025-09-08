Ficha Técnica do Projeto: Análise de Risco de Crédito – Banco Caja
Desenvolvido por: Vanessa Campoy Costa
Data: Setembro de 2025

1. Resumo do Projeto
1.1. Contexto de Negócio
O Banco Caja enfrentava um desafio operacional significativo: um aumento no volume de solicitações de crédito sobrecarregou a equipe, que realizava as análises de forma manual. Esse processo lento e a crescente preocupação com a inadimplência exigiam uma solução que trouxesse mais agilidade e segurança para o banco.

1.2. Meu Objetivo
Meu objetivo com este projeto foi substituir o processo manual por uma solução baseada em dados. Para isso, propus a criação de um score de risco e um dashboard interativo para classificar clientes, automatizar aprovações de baixo risco e permitir que a equipe de crédito definisse suas políticas de forma mais clara e informada.

1.3. Ferramentas Utilizadas
Banco de Dados: Google BigQuery

Linguagem: SQL

Visualização de Dados: Looker Studio

2. Dicionário de Dados
Para este projeto, utilizei 4 tabelas principais que continham os dados de 36.000 clientes do Banco Caja:

| Tabela Original | Meu Nome | Descrição |
| :--- | :--- | :--- |
| `user_info` | `t_informacoes_clientes` | Dados demográficos dos clientes (idade, salário, dependentes). |
| `default` | `t_inadimplencia_clientes` | `flag_inadimplencia`, indicando se um cliente já foi inadimplente. |
| `loans_detail` | `t_detalhes_emprestimos`| Comportamento financeiro (índice de endividamento, histórico de atrasos). |
| `loans_outstanding`| `t_emprestimos_contratados`| Detalhes de cada contrato de empréstimo, como o tipo. |

Com certeza. Entendi perfeitamente. Você quer uma versão final da Ficha Técnica que corrija a numeração e descreva o papel das suas views SQL de forma mais precisa, como partes de um processo, em vez de chamar uma de "principal".

E sim, é muito fácil excluir um arquivo do GitHub. Vou te mostrar como ao final.

Primeiro, aqui está a versão revisada e final da sua Ficha Técnica. Ela está mais limpa e profissional, pronta para o seu portfólio.

Ficha Técnica do Projeto: Análise de Risco de Crédito – Banco Caja
Desenvolvido por: Vanessa Campoy Costa
Data: Setembro de 2025

1. Resumo do Projeto
1.1. Contexto de Negócio
O Banco Caja enfrentava um desafio operacional significativo: um aumento no volume de solicitações de crédito sobrecarregou a equipe, que realizava as análises de forma manual. Esse processo lento e a crescente preocupação com a inadimplência exigiam uma solução que trouxesse mais agilidade e segurança para o banco.

1.2. Meu Objetivo
Meu objetivo com este projeto foi substituir o processo manual por uma solução baseada em dados. Para isso, propus a criação de um score de risco e um dashboard interativo para classificar clientes, automatizar aprovações de baixo risco e permitir que a equipe de crédito definisse suas políticas de forma mais clara e informada.

1.3. Ferramentas Utilizadas
Banco de Dados: Google BigQuery
Linguagem: SQL
Visualização de Dados: Looker Studio

2. Dicionário de Dados
Para este projeto, utilizei 4 tabelas principais que continham os dados de 36.000 clientes do Banco Caja:

| Tabela Original | Meu Nome | Descrição |
| :--- | :--- | :--- |
| `user_info` | `t_informacoes_clientes` | Dados demográficos dos clientes (idade, salário, dependentes). |
| `default` | `t_inadimplencia_clientes` | `flag_inadimplencia`, indicando se um cliente já foi inadimplente. |
| `loans_detail` | `t_detalhes_emprestimos`| Comportamento financeiro (índice de endividamento, histórico de atrasos). |
| `loans_outstanding`| `t_emprestimos_contratados`| Detalhes de cada contrato de empréstimo, como o tipo. |

Exportar para as Planilhas
3. Metodologia da Análise
Conduzi a análise seguindo um processo estruturado, passo a passo:

1. Carga e Estruturação Inicial dos Dados
Iniciei o projeto importando as 4 tabelas de origem para o Google BigQuery e as renomeei para nomes em português para facilitar a análise.

2. Limpeza e Tratamento dos Dados
Realizei uma verificação completa de dados nulos, substituindo os valores ausentes em numero_dependentes por 0. Verifiquei todas as tabelas em busca de registros duplicados e confirmei que não havia nenhum. Por fim, padronizei as colunas de texto, como tipo_emprestimo, para garantir a consistência dos dados.

3. Análise Exploratória e Engenharia de Features
Utilizei o Looker Studio para fazer uma análise exploratória e entender a distribuição de variáveis como idade e salario_mes_anterior, o que me permitiu identificar outliers. Para aprofundar a análise, criei novas colunas (features) para segmentar os clientes, como faixa_etaria.

4. Análise de Correlação e Seleção de Variáveis
Para evitar redundância de informações no modelo, realizei uma análise de correlação (CORR()) entre as variáveis de dias de atraso. A variável mais_90_dias_atraso foi a selecionada, pois apresentou a maior correlação com a inadimplência (0.307).

5. Construção do Score de Risco
Com base nos perfis de risco que identifiquei, construí um scorecard para gerar o score_de_risco de cada cliente. 

6. Validação do Modelo de Score
Para validar a eficácia do score, testei múltiplos pontos de corte (de 2 a 6). Avaliei a performance de cada cenário com uma matriz de confusão e as métricas de Acurácia, Precisão, Recall e F1-Score, o que me permitiu identificar a estratégia com o melhor equilíbrio entre a captura de risco e a eficiência operacional.

7. Scripts SQL
Os códigos SQL completos para as views que utilizei para alimentar o dashboard estão disponíveis na pasta /sql deste repositório. O processo foi dividido em views especializadas para organizar a análise:

01_v_unica.sql:

Finalidade: Esta é a view de preparação de dados. Ela une as 4 tabelas originais, realiza a limpeza dos dados e cria as novas colunas, como: faixa_etaria e o score_de_risco. Ela cria a base de clientes completa, com uma linha por cliente, que alimenta as páginas de análise de perfil do dashboard.

03_v_score_validacao.sql e 04_v_analise_cortes.sql:

Finalidade: Estas são as views de análise de performance. Elas leem os dados da view de preparação e calculam a performance do modelo de score (Precisão, Recall, etc.) para cada um dos cenários de corte. São estas views que alimentam a página interativa de "Classificação por Score".

8. Entregáveis Finais
Dashboard Interativo no Looker Studio:
https://lookerstudio.google.com/reporting/42a5e84c-d7cb-42cf-9cba-6fb903fd1f8e

Apresentação do Projeto:
https://docs.google.com/presentation/d/1rdD61zwfBs6bMZKtprYMuiPibU-X4Itjh6LFMJtr_hQ/edit?usp=sharing




