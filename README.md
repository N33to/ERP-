# ERP de gestão administrativa, financeira e operacional

Sistema web multiusuário, construído do zero, que concentra a administração de uma empresa de serviços de construção civil: pessoal, ponto, financeiro, documentos e obras. Está em produção.

> **Sobre este repositório:** é um software de uso interno de uma empresa real. Por isso **o código-fonte e os dados não são públicos**. Aqui estão a arquitetura, o mapa de pastas ([ESTRUTURA.md](ESTRUTURA.md)) e o esquema do banco ([sql/esquema.sql](sql/esquema.sql)), sem nenhum dado e sem as tabelas e colunas de autenticação.

## Painel

| | |
|---|---|
| **Situação** | Em produção, com evolução contínua |
| **Última revisão de arquitetura** | Novembro de 2026: código sem comentários, funções longas quebradas em etapas, formatadores do front unificados (detalhes abaixo) |
| **Módulos** | 9 |
| **Tabelas** | 91 (75 do núcleo + 16 da operação de obras); 67 publicadas em [sql/esquema.sql](sql/esquema.sql) |
| **Código próprio** | ~83,5 mil linhas, sem comentários e sem bibliotecas de terceiros |
| **Testes** | 456 testes automatizados na suíte principal, todos passando; 49 arquivos de teste |
| **Stack** | PHP 8.2+ · MySQL/MariaDB · JavaScript · HTML · CSS · Python |

## O problema

A operação rodava em planilhas e em três programas de mesa independentes (cadastro de pessoal e ponto, financeiro, separação de documentos). Os mesmos dados viviam em vários arquivos, cada pessoa via tudo ou nada, e fechar o mês dependia de conferência manual.

## A solução

Um site único, com login e abas por perfil, rodando em hospedagem compartilhada (PHP + MySQL), com tudo no banco e as planilhas reduzidas a **importação**.

| Módulo | O que resolve |
|---|---|
| **Colaboradores** | Cadastro, certificados e validades, avisos de vencimento (exames, treinamentos, contrato de experiência) |
| **Ponto mensal** | Digitação do cartão, apuração de horas extras (65/75/100%), DSR e valor em reais, ficha em PDF |
| **Termos mensais** | Geração em lote dos termos do mês, com PDF único para impressão, cruzado com as faltas da folha |
| **Financeiro** | Lançamentos, contas fixas, painel com filtros e planilha de conferência, folha de produção, importação de planilhas, **conciliação bancária** (OFX/CSV/XLSX/PDF), **caixa de entrada** que lê boletos e notas dos e-mails e **notas fiscais** de serviço e de material |
| **Serviços** | Obras, medição da produção, levantamento a partir do projeto em PDF, tabelas de preço e composições, proposta comercial em PDF, orçamento online |
| **Operação de obras** | Estrutura da obra, alocação de equipe, apontamentos e indicadores |
| **Empresas** | Cadastro das empresas do grupo e seus documentos |
| **Scanner (integração)** | Separação e nomeação de PDFs de RH feita em outro programa local, que grava no sistema pela API |
| **Acessos** | Perfis, permissões por módulo e por recurso (sem acesso / consulta / altera), autenticação em duas etapas e auditoria |

## Arquitetura

```text
navegador ── um .js por tela + base comum (chamadas, janelas, formatadores)
    │  POST JSON, cabeçalho anti-CSRF
    ▼
api.php ── despachante: método -> módulo pelo prefixo, permissão declarada em atributo
    │       (#[Permissao], #[Recurso]), proteção contra clique duplo, auditoria
    ▼
app/modulos/<módulo>/Api.php ── tradução fina para a tela, sem regra de negócio
    ▼
app/modulos/<módulo>/*.php ── regras de negócio (uma classe por assunto)
    ▼
app/nucleo/ ── banco (PDO), sessão em tabela, PDF, DOCX, XLSX sem bibliotecas
    ▼
MySQL
```

- **Sem framework e sem Composer.** A hospedagem compartilhada só tem PHP e MySQL; a única dependência é uma classe de PDF.
- **Permissão conferida no servidor.** Todo método que grava declara o nível exigido; a tela apenas esconde o que não se pode usar.
- **Dinheiro em centavos inteiros e datas em ISO** no banco. Nunca `float`.
- **Nada é apagado de fato.** Cadastros saem de uso, e toda ação relevante deixa linha de auditoria.
- **Uma régua por pergunta.** "Estes dois lançamentos são o mesmo?", "quais linhas entram neste número?" e "este prazo vence quando?" têm uma única implementação cada, usada por painel, lista, planilha e importação, e há teste provando que contam as mesmas linhas.
- **Três regimes no financeiro** (caixa, competência e vencimento), porque o mesmo mês tem três números corretos e misturá-los é o que faz planilhas deixarem de fechar.
- **Migração verificada, não suposta.** Na troca dos programas de mesa pelo site, os fechamentos de ponto e de financeiro de vários meses foram recalculados e **bateram número a número** com a versão anterior (testes de referência).

## Revisão de arquitetura (novembro de 2026)

Uma limpeza do código inteiro, feita sem mudar nenhum comportamento:

- **Código sem comentários.** Os mais de 7 mil comentários saíram dos arquivos, e o conteúdo deles foi para `docs/regras/`, organizado por módulo, arquivo e função. O código diz *o que* faz; o *porquê* de cada regra fica documentado num lugar só.
- **Funções longas quebradas em etapas com nome.** A montagem da lista de notas fiscais de fornecedores (375 linhas) virou 11 etapas; a fila de boletos dos e-mails e as pendências da tela inicial seguiram o mesmo caminho. Uma data de referência que era calculada de quatro jeitos ligeiramente diferentes passou a ter uma única definição.
- **Front sem cópias.** Formatadores de dinheiro, data e contagem que estavam repetidos em sete telas passaram a vir de um único lugar da base comum.
- **Código morto removido**, inclusive importações sem uso.

**Como se provou que nada mudou:**

1. Os tokens de cada arquivo PHP e JavaScript e a árvore sintática de cada arquivo Python foram comparados antes e depois: idênticos, fora os comentários.
2. Para cada função reorganizada, a saída foi gravada sobre os dados reais **antes** da mudança e comparada byte a byte **depois** (mesmo hash SHA-256).
3. A suíte de 456 testes passou do início ao fim de cada etapa, e a conferência automática das telas no navegador (desktop e celular) não acusou nenhum erro.

## Contato

[LinkedIn](https://www.linkedin.com/in/jos3martins/) · [N33to](https://github.com/N33to)
