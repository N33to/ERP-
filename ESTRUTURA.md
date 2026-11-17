# Estrutura do projeto

Mapa das pastas e arquivos de código. O código-fonte não é publicado neste repositório
(é software de uso interno de uma empresa real); aqui fica a arquitetura.

```text
├── app/   # código de aplicação (PHP, sem Composer)
│   ├── modulos/   # um diretório por módulo (aba) do sistema
│   │   ├── acesso/
│   │   │   ├── Api.php
│   │   │   └── Central.php
│   │   ├── colaboradores/
│   │   │   ├── Api.php
│   │   │   └── Cadastro.php
│   │   ├── empresas/
│   │   │   ├── Api.php
│   │   │   └── Empresas.php
│   │   ├── financeiro/
│   │   │   ├── Anexos.php
│   │   │   ├── Api.php
│   │   │   ├── Catalogo.php
│   │   │   ├── ContasFixas.php
│   │   │   ├── Importacao.php
│   │   │   ├── Lancamentos.php
│   │   │   ├── Listas.php
│   │   │   ├── Painel.php
│   │   │   └── Relatorios.php
│   │   ├── ponto/
│   │   │   ├── Api.php
│   │   │   ├── Dados.php
│   │   │   ├── Ficha.php
│   │   │   ├── Regras.php
│   │   │   ├── Relatorio.php
│   │   │   ├── RelatorioPdf.php
│   │   │   └── Valores.php
│   │   ├── scanner/
│   │   │   └── Api.php
│   │   ├── servicos/
│   │   │   ├── Api.php
│   │   │   ├── Aprendizado.php
│   │   │   ├── Documentos.php
│   │   │   ├── DocumentosApi.php
│   │   │   ├── Estudo.php
│   │   │   ├── Levantamento.php
│   │   │   ├── ListaMateriais.php
│   │   │   ├── Obras.php
│   │   │   ├── Orcamento.php
│   │   │   ├── Precificacao.php
│   │   │   └── Proposta.php
│   │   └── termos/
│   │       ├── Api.php
│   │       └── Termos.php
│   ├── nucleo/   # núcleo: banco, rotas, permissões, auditoria
│   │   ├── Acesso.php
│   │   ├── Api.php
│   │   ├── Arquivo.php
│   │   ├── Auditoria.php
│   │   ├── Banco.php
│   │   ├── Config.php
│   │   ├── DocumentosDrive.php
│   │   ├── Docx.php
│   │   ├── DocxPdf.php
│   │   ├── ErroDeApi.php
│   │   ├── Pdf.php
│   │   ├── Permissao.php
│   │   ├── Requisicao.php
│   │   ├── Sessao.php
│   │   ├── Util.php
│   │   └── Xlsx.php
│   ├── bootstrap.php
│   ├── config.local.exemplo.php
│   └── config.php
├── public/   # única pasta exposta na web
│   ├── assets/
│   │   ├── css/
│   │   │   ├── app.css
│   │   │   ├── site.css
│   │   │   └── tema.css
│   │   └── js/
│   │       ├── acessos.js
│   │       ├── app.js
│   │       ├── colaboradores.js
│   │       ├── documentos.js
│   │       ├── empresas.js
│   │       ├── financeiro.js
│   │       ├── graficos.js
│   │       ├── ponto.js
│   │       ├── projeto.js
│   │       ├── scanner.js
│   │       ├── servicos.js
│   │       └── termos.js
│   ├── api.php
│   ├── index.php
│   ├── raiz.exemplo.php
│   └── sistema.php
├── scripts/   # instalação, migração e conferências
│   ├── conferir_duplicados.ps1
│   ├── conferir_projeto.ps1
│   ├── conferir_visual.ps1
│   ├── conferir_web.ps1
│   ├── empacotar_deploy.ps1
│   ├── estudo.php
│   ├── exportar_supabase.php
│   ├── gerar_calculadora_orcamento.py
│   ├── importar_documentos_supabase.py
│   ├── instalar.php
│   ├── mariadb_local.ps1
│   ├── migrar.php
│   ├── mvp.ps1
│   ├── servidor_local.ps1
│   ├── sincronizar_acessos.php
│   └── supabase_db.py
├── sql/   # esquema do banco (ver sql/esquema.sql)
│   └── esquema.sql
└── tests/   # testes automatizados (regras de negócio e navegador)
    ├── _gerar_termos.py
    ├── config.teste.php
    ├── fumaca_api.py
    ├── gerar_golden_financeiro.py
    ├── gerar_golden_ponto.py
    ├── gerar_golden_precificacao.py
    ├── gerar_golden_servicos.py
    ├── pagina_conferir_web.html
    ├── pagina_duplicados.html
    ├── pagina_navegacao.html
    ├── pagina_projeto.html
    ├── pagina_responsivo.html
    ├── rodar.php
    ├── test_acesso_e_financeiro.php
    ├── test_contas_fixas_e_documentos.php
    ├── test_documentos.php
    ├── test_financeiro_golden.php
    ├── test_nucleo.php
    ├── test_ponto_golden.php
    ├── test_ponto_regras.php
    ├── test_precificacao.php
    └── test_servicos_golden.php
```

## Tamanho (linhas, sem bibliotecas de terceiros)

| Linguagem | Linhas |
|---|---:|
| PHP | 26.918 |
| JavaScript | 12.592 |
| CSS | 3.123 |
| Python | 2.294 |
| SQL | 1.379 |
| HTML | 478 |
| PowerShell | 247 |

_Arquivos: 113._
