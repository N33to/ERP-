# Estrutura do projeto

Mapa das pastas e arquivos de código. O código-fonte não é publicado neste repositório
(é software de uso interno de uma empresa real); aqui fica a arquitetura.
Arquivos de autenticação, sessão, criptografia, publicação e testes de invasão ficam fora deste mapa de propósito.

```text
├── app/   # código de aplicação (PHP, sem Composer)
│   ├── modulos/   # um diretório por módulo (aba) do sistema
│   │   ├── acesso/
│   │   │   ├── Agenda.php
│   │   │   ├── Api.php
│   │   │   └── Central.php
│   │   ├── colaboradores/
│   │   │   ├── Alertas.php
│   │   │   ├── Api.php
│   │   │   ├── Cadastro.php
│   │   │   └── Certificados.php
│   │   ├── empresas/
│   │   │   ├── Api.php
│   │   │   └── Empresas.php
│   │   ├── financeiro/
│   │   │   ├── conciliacao/
│   │   │   │   ├── ApiExtratos.php
│   │   │   │   ├── Aprendizado.php
│   │   │   │   ├── ContasBancarias.php
│   │   │   │   ├── Importador.php
│   │   │   │   ├── Motor.php
│   │   │   │   └── Vinculo.php
│   │   │   ├── extrato/
│   │   │   │   ├── Dinheiro.php
│   │   │   │   ├── LeitorCsv.php
│   │   │   │   ├── LeitorOfx.php
│   │   │   │   ├── LeitorPdfTexto.php
│   │   │   │   ├── LeitorTabular.php
│   │   │   │   ├── LeitorXlsx.php
│   │   │   │   ├── Leitura.php
│   │   │   │   ├── Normalizador.php
│   │   │   │   └── Texto.php
│   │   │   ├── Anexos.php
│   │   │   ├── Api.php
│   │   │   ├── Boleto.php
│   │   │   ├── BoletoLido.php
│   │   │   ├── Caixa.php
│   │   │   ├── Catalogo.php
│   │   │   ├── Conciliacao.php
│   │   │   ├── ContasFixas.php
│   │   │   ├── Filtro.php
│   │   │   ├── Importacao.php
│   │   │   ├── Lancamentos.php
│   │   │   ├── Listas.php
│   │   │   ├── NotaFiscal.php
│   │   │   ├── NotasMaterial.php
│   │   │   ├── NotasPeriodo.php
│   │   │   ├── Painel.php
│   │   │   ├── PainelExcel.php
│   │   │   ├── Producao.php
│   │   │   ├── ProducaoArquivos.php
│   │   │   └── Relatorios.php
│   │   ├── operacao/
│   │   │   ├── Alocacao.php
│   │   │   ├── Api.php
│   │   │   ├── Apontamentos.php
│   │   │   ├── ConciliacaoPonto.php
│   │   │   ├── Estrutura.php
│   │   │   ├── Indicadores.php
│   │   │   ├── Materiais.php
│   │   │   ├── MedicaoSugestoes.php
│   │   │   ├── Painel.php
│   │   │   ├── Regras.php
│   │   │   └── Vinculos.php
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
│   │   │   ├── Espelho.php
│   │   │   ├── Estudo.php
│   │   │   ├── ImportarPlanilha.php
│   │   │   ├── Levantamento.php
│   │   │   ├── ListaMateriais.php
│   │   │   ├── Materiais.php
│   │   │   ├── Medicao.php
│   │   │   ├── NotaLida.php
│   │   │   ├── Obras.php
│   │   │   ├── Orcamento.php
│   │   │   ├── OrcamentoSite.php
│   │   │   ├── Precificacao.php
│   │   │   ├── Precos.php
│   │   │   ├── Proposta.php
│   │   │   └── SiteApi.php
│   │   └── termos/
│   │       ├── Api.php
│   │       ├── FolhaDeLote.php
│   │       └── Termos.php
│   ├── nucleo/   # núcleo: banco, rotas, permissões, auditoria
│   │   ├── Acesso.php
│   │   ├── Api.php
│   │   ├── Arquivo.php
│   │   ├── Auditoria.php
│   │   ├── Banco.php
│   │   ├── Config.php
│   │   ├── Conteudo.php
│   │   ├── DocumentosDrive.php
│   │   ├── DocumentosZip.php
│   │   ├── Docx.php
│   │   ├── DocxPdf.php
│   │   ├── ErroDeApi.php
│   │   ├── GoogleDrive.php
│   │   ├── Idempotencia.php
│   │   ├── Pdf.php
│   │   ├── Permissao.php
│   │   ├── Recurso.php
│   │   ├── Requisicao.php
│   │   ├── SoAdmin.php
│   │   ├── Util.php
│   │   ├── Whatsapp.php
│   │   └── Xlsx.php
│   ├── bootstrap.php
│   ├── config.local.exemplo.php
│   └── config.php
├── docs/   # documentação
│   └── regras/   # o porquê de cada regra, por módulo, arquivo e função (conteúdo não publicado)
│       ├── README.md
│       ├── acesso.md
│       ├── banco.md
│       ├── colaboradores.md
│       ├── configuracao.md
│       ├── empresas.md
│       ├── financeiro.md
│       ├── nucleo.md
│       ├── operacao.md
│       ├── ponto.md
│       ├── scanner.md
│       ├── scripts.md
│       ├── servicos.md
│       ├── site-e-paginas.md
│       ├── telas.md
│       ├── termos.md
│       └── testes.md
├── public/   # única pasta exposta na web
│   ├── assets/
│   │   ├── css/
│   │   │   ├── app.css
│   │   │   ├── modelo.css
│   │   │   ├── operacao.css
│   │   │   ├── orcar.css
│   │   │   ├── site.css
│   │   │   └── tema.css
│   │   └── js/
│   │       ├── acessos.js
│   │       ├── app.js
│   │       ├── boleto.js
│   │       ├── caixa.js
│   │       ├── colaboradores.js
│   │       ├── conciliacao.js
│   │       ├── confirmacoes.js
│   │       ├── documentos.js
│   │       ├── empresas.js
│   │       ├── entrar.js
│   │       ├── financeiro.js
│   │       ├── graficos.js
│   │       ├── medicao.js
│   │       ├── notas-material.js
│   │       ├── notas-periodo.js
│   │       ├── operacao-alocacao.js
│   │       ├── operacao-consulta.js
│   │       ├── operacao-indicadores.js
│   │       ├── operacao-integracoes.js
│   │       ├── operacao-obras.js
│   │       ├── operacao.js
│   │       ├── orcar.js
│   │       ├── ponto.js
│   │       ├── precos.js
│   │       ├── producao.js
│   │       ├── projeto-desenho.js
│   │       ├── projeto-preparo.js
│   │       ├── projeto.js
│   │       ├── scanner.js
│   │       ├── servicos.js
│   │       ├── site-efeitos.js
│   │       └── termos.js
│   ├── api.php
│   ├── index.php
│   ├── orcar.php
│   ├── raiz.exemplo.php
│   └── sistema.php
├── scripts/   # instalação, migração e conferências
│   ├── experimental/
│   │   ├── demo_operacao.ps1
│   │   ├── demonstracao.php
│   │   └── operacao.php
│   ├── agenda_whatsapp.php
│   ├── boletos_esperado.php
│   ├── caixa.ps1
│   ├── caixa_absorver.php
│   ├── caixa_coletar.py
│   ├── caixa_enviar.py
│   ├── conferir_duplicados.ps1
│   ├── conferir_projeto.ps1
│   ├── conferir_visual.ps1
│   ├── conferir_web.ps1
│   ├── empacotar_deploy.ps1
│   ├── estudo.php
│   ├── exportar_producao_planilha.py
│   ├── exportar_supabase.php
│   ├── foto_financeiro.php
│   ├── gerar_calculadora_orcamento.py
│   ├── gerar_fonte_fpdf.py
│   ├── gerar_modelo_envelope.py
│   ├── gerar_modelo_folha.py
│   ├── gerar_modelo_proposta.py
│   ├── gerar_taxas_historicas_medicao.py
│   ├── importar_documentos_supabase.py
│   ├── importar_folha_supabase.py
│   ├── importar_producao.php
│   ├── instalar.php
│   ├── mariadb_local.ps1
│   ├── migrar.php
│   ├── mvp.ps1
│   ├── servidor_local.ps1
│   ├── sincronizar_acessos.php
│   └── supabase_db.py
├── sql/   # esquema do banco (ver sql/esquema.sql)
│   ├── experimental/
│   │   ├── operacao_down.sql
│   │   ├── operacao_integracoes_down.sql
│   │   ├── operacao_integracoes_up.sql
│   │   └── operacao_up.sql
│   ├── migracoes/
│   │   ├── 2026.11.11.2.desfazer.sql
│   │   ├── 2026.11.11.2.sql
│   │   ├── 2026.11.12.1.desfazer.sql
│   │   ├── 2026.11.12.1.sql
│   │   ├── 2026.11.13.1.desfazer.sql
│   │   └── 2026.11.13.1.sql
│   └── esquema.sql
├── tests/   # testes automatizados (regras de negócio e navegador)
│   ├── experimental/
│   │   ├── conferir_2d_indicadores.js
│   │   ├── conferir_integracoes.js
│   │   ├── conferir_planta_flexivel.js
│   │   ├── rodar_integracoes.php
│   │   ├── rodar_operacao.php
│   │   └── rodar_painel.php
│   ├── _ajuda_conciliacao.php
│   ├── _gerar_termos.py
│   ├── _medicao_folha.php
│   ├── abrir_pagina.js
│   ├── conferir_baixar_docs.js
│   ├── conferir_baixar_zip.js
│   ├── conferir_boleto.js
│   ├── conferir_dicas.js
│   ├── conferir_fase2_telas.js
│   ├── conferir_levantamento.js
│   ├── conferir_medicao.js
│   ├── conferir_notas.js
│   ├── conferir_notas_conferencia.js
│   ├── conferir_ordem_notas.js
│   ├── conferir_paredes_proposta.js
│   ├── conferir_planta_medidas.js
│   ├── conferir_precos.js
│   ├── conferir_preparo.js
│   ├── conferir_somar_mao.js
│   ├── conferir_status_notas.js
│   ├── conferir_termos_lote.js
│   ├── fumaca_api.py
│   ├── gerar_golden_financeiro.py
│   ├── gerar_golden_ponto.py
│   ├── gerar_golden_precificacao.py
│   ├── gerar_golden_servicos.py
│   ├── gerar_pdfs_medidas.py
│   ├── ler_projeto.js
│   ├── pagina_conferir_web.html
│   ├── pagina_duplicados.html
│   ├── pagina_navegacao.html
│   ├── pagina_projeto.html
│   ├── pagina_responsivo.html
│   ├── rodar.php
│   ├── test_acesso_e_financeiro.php
│   ├── test_agenda_whatsapp.php
│   ├── test_anexo_autorizacao.php
│   ├── test_boleto.php
│   ├── test_caixa.php
│   ├── test_caixa_coletor.py
│   ├── test_categorias_movimentacao.php
│   ├── test_certificados_nr.php
│   ├── test_colaboradores_alertas.php
│   ├── test_conciliacao_api.php
│   ├── test_conciliacao_diferenca.php
│   ├── test_conciliacao_esquema.php
│   ├── test_conciliacao_motor.php
│   ├── test_conciliacao_vinculo.php
│   ├── test_contas_fixas_e_documentos.php
│   ├── test_documentos.php
│   ├── test_documentos_zip.php
│   ├── test_extrato_leitores.php
│   ├── test_extrato_persistencia.php
│   ├── test_fase2_identidade.php
│   ├── test_financeiro_golden.php
│   ├── test_gestao_financeira.php
│   ├── test_idempotencia.php
│   ├── test_identidade_lancamentos.php
│   ├── test_integridade_financeiro.php
│   ├── test_lancamentos_em_lote.php
│   ├── test_levantamento_quantidade.php
│   ├── test_medicao.php
│   ├── test_nota_lida.php
│   ├── test_notas_conferencia.php
│   ├── test_notas_periodo.php
│   ├── test_nucleo.php
│   ├── test_orcamento_site.php
│   ├── test_painel_conferencia.php
│   ├── test_ponto_golden.php
│   ├── test_ponto_regras.php
│   ├── test_precificacao.php
│   ├── test_precos_composicoes.php
│   ├── test_producao.php
│   ├── test_proposta.php
│   ├── test_recursos.php
│   ├── test_servicos_golden.php
│   ├── test_termos_lote.php
│   └── treino_medicao_historico.php
└── ESTRUTURA_TODOS_OS_BANCOS.sql
```

## Tamanho (linhas, sem bibliotecas de terceiros e sem comentários)

| Linguagem | Linhas |
|---|---:|
| PHP | 49.461 |
| JavaScript | 21.857 |
| SQL | 4.390 |
| Python | 4.088 |
| CSS | 3.076 |
| HTML | 431 |
| PowerShell | 253 |

_Arquivos: 283._
