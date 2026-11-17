# ERP de gestão administrativa, financeira e operacional

Sistema web multiusuário, construído do zero, que concentra a administração de uma empresa de serviços de construção civil: pessoal, ponto, financeiro, documentos e obras. Está em produção.

> **Sobre este repositório:** é um software de uso interno de uma empresa real. Por isso **o código-fonte e os dados não são públicos**. Aqui estão a arquitetura, o mapa de pastas ([ESTRUTURA.md](ESTRUTURA.md)) e o esquema do banco ([sql/esquema.sql](sql/esquema.sql)), sem nenhum dado e sem as tabelas de autenticação.

## O problema

A operação rodava em planilhas e em três programas de mesa independentes (cadastro de pessoal e ponto, financeiro, separação de documentos). Os mesmos dados viviam em vários arquivos, cada pessoa via tudo ou nada, e fechar o mês dependia de conferência manual.

## A solução

Um site único, com login e abas por perfil, rodando em hospedagem compartilhada (PHP + MySQL), com tudo no banco e as planilhas reduzidas a **importação**.

| Módulo | O que resolve |
|---|---|
| **Colaboradores** | Cadastro, certificados e validades, avisos de vencimento |
| **Ponto mensal** | Digitação do cartão, apuração de horas extras (65/75/100%), DSR e valor em reais, ficha em PDF |
| **Termos mensais** | Geração em lote dos termos do mês, com PDF único para impressão |
| **Financeiro** | Lançamentos, contas fixas, notas fiscais, calendário, painel com filtros, importação de planilhas e **conciliação bancária** |
| **Serviços** | Obras, medição da produção, levantamento de forro a partir do projeto em PDF, tabelas de preço e composições, orçamento online |
| **Scanner (integração)** | Separação e nomeação de PDFs de RH feita em outro programa local, que grava no sistema pela API |
| **Acessos** | Perfis, permissões por módulo (sem acesso / consulta / altera) e auditoria |

## Decisões de engenharia

- **PHP 8.2+ e MySQL, sem Composer.** Hospedagem compartilhada só tem isso; a única dependência é uma classe de PDF.
- **Permissão conferida no servidor.** Todo método que grava declara o nível exigido; a tela apenas esconde o que não se pode usar.
- **Dinheiro em centavos inteiros e datas em ISO** no banco. Nunca `float`.
- **Nada é apagado de fato.** Cadastros saem de uso, e toda ação relevante deixa linha de auditoria.
- **Importação reversível.** Todo lote importado é marcado e pode ser desfeito sem encostar no que foi digitado à mão.
- **Três regimes no financeiro** (caixa, competência e vencimento), porque o mesmo mês tem três números corretos e misturá-los é o que faz planilhas deixarem de fechar.
- **Migração verificada, não suposta.** Na troca dos programas de mesa pelo site, os fechamentos de ponto e de financeiro de vários meses foram recalculados e **bateram número a número** com a versão anterior (testes de referência).

## Em números

Medidos no próprio código:

- **9 módulos** e **74 tabelas** no banco
- ~**47 mil linhas** de código próprio (PHP, JavaScript, CSS, SQL e scripts), fora bibliotecas de terceiros
- **42 arquivos de teste automatizado**, incluindo testes de referência que comparam o resultado com a versão anterior
- Cadastro com mais de **50 colaboradores** (ativos e desligados) migrados das planilhas

## Stack

PHP 8.2+ · MySQL/MariaDB · JavaScript · HTML · CSS · Python (cliente de escaneamento) · Supabase (espelho de dados auxiliares) · Git

## Contato

[LinkedIn](https://www.linkedin.com/in/jos3martins/) · [N33to](https://github.com/N33to)
