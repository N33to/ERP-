SET NAMES utf8mb4;

SET time_zone = '-03:00';

CREATE TABLE IF NOT EXISTS perfis (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome        VARCHAR(60)  NOT NULL,
  descricao   VARCHAR(200) NOT NULL DEFAULT '',
  admin       TINYINT(1)   NOT NULL DEFAULT 0,
  fixo        TINYINT(1)   NOT NULL DEFAULT 0,
  ordem       INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY perfis_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS perfil_modulos (
  perfil_id   INT UNSIGNED NOT NULL,
  modulo      VARCHAR(40)  NOT NULL,
  nivel       VARCHAR(10)  NOT NULL DEFAULT 'nenhum',
  PRIMARY KEY (perfil_id, modulo),
  CONSTRAINT fk_perfil_modulos_perfil FOREIGN KEY (perfil_id) REFERENCES perfis(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS perfil_bloqueios (
  perfil_id   INT UNSIGNED NOT NULL,
  modulo      VARCHAR(40)  NOT NULL,
  recurso     VARCHAR(40)  NOT NULL,
  PRIMARY KEY (perfil_id, modulo, recurso),
  CONSTRAINT fk_perfil_bloqueios_perfil FOREIGN KEY (perfil_id) REFERENCES perfis(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS usuarios (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome          VARCHAR(120) NOT NULL,
  login         VARCHAR(60)  NOT NULL,
  email         VARCHAR(160) NULL,
  perfil_id     INT UNSIGNED NOT NULL,
  ativo         TINYINT(1)   NOT NULL DEFAULT 1,
  trocar_senha  TINYINT(1)   NOT NULL DEFAULT 0,
  criado_em     DATETIME     NOT NULL,
  ultimo_acesso DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY usuarios_login (login),
  KEY usuarios_perfil (perfil_id),
  CONSTRAINT fk_usuarios_perfil FOREIGN KEY (perfil_id) REFERENCES perfis(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS auditoria (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id  INT UNSIGNED NULL,
  usuario     VARCHAR(60)  NOT NULL DEFAULT '',
  quando      DATETIME     NOT NULL,
  modulo      VARCHAR(40)  NOT NULL,
  acao        VARCHAR(60)  NOT NULL,
  detalhe     TEXT         NULL,
  alvo        VARCHAR(80)  NULL,
  resultado   VARCHAR(12)  NULL,
  origem      VARCHAR(12)  NULL,
  ip          VARCHAR(45)  NULL,
  PRIMARY KEY (id),
  KEY auditoria_quando (quando),
  KEY auditoria_modulo (modulo, quando)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ajustes (
  chave  VARCHAR(60)  NOT NULL,
  valor  TEXT         NULL,
  PRIMARY KEY (chave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS colaboradores (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_planilha     BIGINT       NULL,
  chave           VARCHAR(140) NOT NULL,
  nome            VARCHAR(140) NOT NULL,
  nome_normalizado VARCHAR(140) NOT NULL,
  status          VARCHAR(30)  NOT NULL DEFAULT 'Ativo',
  cpf             VARCHAR(14)  NULL,
  cpf_digitos     CHAR(11)     NULL,
  nascimento      DATE         NULL,
  cargo           VARCHAR(80)  NULL,
  salario         DECIMAL(12,2) NULL,
  admissao        DATE         NULL,
  empresa         VARCHAR(120) NULL,
  cnpj            VARCHAR(20)  NULL,
  endereco        VARCHAR(255) NULL,
  aso_emissao     DATE         NULL,
  aso_vencimento  DATE         NULL,
  observacao      TEXT         NULL,
  origem          VARCHAR(20)  NOT NULL DEFAULT 'tela',
  criado_em       DATETIME     NOT NULL,
  atualizado_em   DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY colaboradores_chave (chave),
  KEY colaboradores_cpf (cpf_digitos),
  KEY colaboradores_nome (nome_normalizado),
  KEY colaboradores_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS colab_certificados (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  colaborador_id  INT UNSIGNED NOT NULL,
  documento       VARCHAR(30)  NOT NULL,
  realizado_em    DATE         NULL,
  validade_em     DATE         NOT NULL,
  atualizado_em   DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY colab_cert_unico (colaborador_id, documento),
  KEY colab_cert_validade (validade_em)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS empresas (
  id                        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  apelido                   VARCHAR(80)  NOT NULL,
  razao_social              VARCHAR(160) NOT NULL,
  nome_fantasia             VARCHAR(160) NULL,
  cnpj                      VARCHAR(20)  NOT NULL,
  cnpj_digitos              CHAR(14)     NOT NULL,
  inscricao_estadual        VARCHAR(30)  NULL,
  abertura                  DATE         NULL,
  porte                     VARCHAR(60)  NULL,
  natureza_juridica         VARCHAR(80)  NULL,
  mei                       VARCHAR(5)   NULL,
  simples                   VARCHAR(5)   NULL,
  simples_desde             DATE         NULL,
  capital_social            VARCHAR(30)  NULL,
  tipo                      VARCHAR(20)  NULL,
  situacao                  VARCHAR(20)  NULL,
  situacao_desde            DATE         NULL,
  logradouro                VARCHAR(160) NULL,
  complemento               VARCHAR(80)  NULL,
  bairro                    VARCHAR(80)  NULL,
  cep                       VARCHAR(10)  NULL,
  municipio                 VARCHAR(80)  NULL,
  estado                    VARCHAR(40)  NULL,
  correspondencia           TEXT         NULL,
  socios                    TEXT         NULL,
  qualificacao_responsavel  VARCHAR(60)  NULL,
  ordem                     INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY empresas_cnpj (cnpj_digitos)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ponto_jornada (
  colaborador   VARCHAR(140) NOT NULL,
  entrada       CHAR(5) NULL,
  almoco_saida  CHAR(5) NULL,
  almoco_volta  CHAR(5) NULL,
  saida         CHAR(5) NULL,
  saida_sexta   CHAR(5) NULL,
  sabado        VARCHAR(30) NULL,
  domingo       VARCHAR(30) NULL,
  atualizado_em DATETIME NULL,
  PRIMARY KEY (colaborador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ponto_cartao (
  colaborador   VARCHAR(140) NOT NULL,
  competencia   CHAR(7)      NOT NULL,
  nome          VARCHAR(140) NULL,
  cargo         VARCHAR(80)  NULL,
  empresa       VARCHAR(120) NULL,
  cnpj          VARCHAR(20)  NULL,
  admissao      VARCHAR(10)  NULL,
  origem        VARCHAR(80)  NULL,
  atualizado_em DATETIME     NULL,
  PRIMARY KEY (colaborador, competencia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ponto_dia (
  colaborador    VARCHAR(140) NOT NULL,
  data           DATE         NOT NULL,
  manha_entrada  SMALLINT     NULL,
  manha_saida    SMALLINT     NULL,
  tarde_entrada  SMALLINT     NULL,
  tarde_saida    SMALLINT     NULL,
  marcador       VARCHAR(30)  NULL,
  marcador_manha VARCHAR(30)  NULL,
  marcador_tarde VARCHAR(30)  NULL,
  observacao     VARCHAR(255) NULL,
  PRIMARY KEY (colaborador, data),
  KEY ponto_dia_data (data)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ponto_remuneracao (
  colaborador   VARCHAR(140) NOT NULL,
  competencia   CHAR(7)      NOT NULL,
  salario       DECIMAL(12,2) NULL,
  divisor       INT          NULL,
  atualizado_em DATETIME     NULL,
  PRIMARY KEY (colaborador, competencia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ponto_feriado (
  data  DATE         NOT NULL,
  nome  VARCHAR(80)  NULL,
  ativo TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (data)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS termos_gerados (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id   INT UNSIGNED NULL,
  quando       DATETIME     NOT NULL,
  tipo         VARCHAR(20)  NOT NULL,
  competencia  CHAR(7)      NOT NULL,
  rotulo       VARCHAR(10)  NOT NULL,
  data_termo   VARCHAR(10)  NOT NULL,
  colaborador  VARCHAR(140) NOT NULL,
  nome         VARCHAR(140) NOT NULL,
  arquivo_pdf  VARCHAR(255) NULL,
  arquivo_docx VARCHAR(255) NULL,
  PRIMARY KEY (id),
  KEY termos_comp (competencia, tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_categorias (
  id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  grupo  VARCHAR(60)  NOT NULL,
  nome   VARCHAR(80)  NOT NULL,
  tipo   VARCHAR(10)  NOT NULL,
  ativa  TINYINT(1)   NOT NULL DEFAULT 1,
  ordem  INT          NOT NULL DEFAULT 0,
  subgrupo VARCHAR(60) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_categorias_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_contas (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, nome VARCHAR(80) NOT NULL,
  ativa TINYINT(1) NOT NULL DEFAULT 1, ordem INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id), UNIQUE KEY fin_contas_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_tipos_venda (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, nome VARCHAR(80) NOT NULL,
  ativa TINYINT(1) NOT NULL DEFAULT 1, ordem INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id), UNIQUE KEY fin_tipos_venda_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_status_obra (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, nome VARCHAR(80) NOT NULL,
  ativa TINYINT(1) NOT NULL DEFAULT 1, ordem INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id), UNIQUE KEY fin_status_obra_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_consultores (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, nome VARCHAR(80) NOT NULL,
  ativa TINYINT(1) NOT NULL DEFAULT 1, ordem INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id), UNIQUE KEY fin_consultores_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_formas_pagamento (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, nome VARCHAR(80) NOT NULL,
  ativa TINYINT(1) NOT NULL DEFAULT 1, ordem INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id), UNIQUE KEY fin_formas_pagamento_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_fornecedores (
  id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome   VARCHAR(140) NOT NULL,
  cnpj   VARCHAR(20)  NULL,
  categoria_padrao_id INT UNSIGNED NULL,
  ativa  TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY fin_fornecedores_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_lancamentos (
  id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo             VARCHAR(10)  NOT NULL,
  valor_centavos   BIGINT       NOT NULL,
  descricao        VARCHAR(255) NOT NULL,
  data_emissao     DATE         NOT NULL,
  data_competencia DATE         NOT NULL,
  data_vencimento  DATE         NOT NULL,
  data_pagamento   DATE         NULL,
  categoria_id     INT UNSIGNED NULL,
  fornecedor_id    INT UNSIGNED NULL,
  conta_id         INT UNSIGNED NULL,
  tipo_venda_id    INT UNSIGNED NULL,
  status_obra_id   INT UNSIGNED NULL,
  consultor_id     INT UNSIGNED NULL,
  obra             VARCHAR(160) NULL,
  forma_pagamento  VARCHAR(60)  NULL,
  status           VARCHAR(30)  NOT NULL DEFAULT 'Pendente',
  origem           VARCHAR(10)  NOT NULL DEFAULT 'MANUAL',
  linha_digitavel  VARCHAR(60)  NULL,
  hash_arquivo     CHAR(64)     NULL,
  valor_documento_centavos BIGINT NULL,
  chave_externa    VARCHAR(80)  NULL,
  lote_importacao  VARCHAR(60)  NULL,
  grupo_parcelas   VARCHAR(20)  NULL,
  parcela          INT          NULL,
  total_parcelas   INT          NULL,
  anexo_path       VARCHAR(255) NULL,
  nota_fiscal_numero VARCHAR(40) NULL,
  nota_fiscal_path VARCHAR(255) NULL,
  confianca        DOUBLE       NULL,
  observacao       TEXT         NULL,
  usuario_id       INT UNSIGNED NULL,
  created_at       DATETIME     NOT NULL,
  updated_at       DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_lanc_linha (linha_digitavel),
  UNIQUE KEY fin_lanc_chave (chave_externa),
  KEY fin_lanc_venc (data_vencimento, status),
  KEY fin_lanc_comp (data_competencia, tipo),
  KEY fin_lanc_pgto (data_pagamento),
  KEY fin_lanc_cat  (categoria_id),
  KEY fin_lanc_hash (hash_arquivo),
  KEY fin_lanc_lote (lote_importacao),
  CONSTRAINT fk_fin_lanc_categoria  FOREIGN KEY (categoria_id)   REFERENCES fin_categorias(id),
  CONSTRAINT fk_fin_lanc_fornecedor FOREIGN KEY (fornecedor_id)  REFERENCES fin_fornecedores(id),
  CONSTRAINT fk_fin_lanc_conta      FOREIGN KEY (conta_id)       REFERENCES fin_contas(id),
  CONSTRAINT fk_fin_lanc_tipo_venda FOREIGN KEY (tipo_venda_id)  REFERENCES fin_tipos_venda(id),
  CONSTRAINT fk_fin_lanc_status_obra FOREIGN KEY (status_obra_id) REFERENCES fin_status_obra(id),
  CONSTRAINT fk_fin_lanc_consultor  FOREIGN KEY (consultor_id)   REFERENCES fin_consultores(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_extrato_itens (
  id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  fitid VARCHAR(80)  NOT NULL,
  data  DATE         NOT NULL,
  valor_centavos BIGINT NOT NULL,
  memo  VARCHAR(255) NULL,
  conta_id      INT UNSIGNED NULL,
  lancamento_id INT UNSIGNED NULL,
  importado_em  DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_extrato_fitid (fitid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_eventos (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  lancamento_id INT UNSIGNED NULL,
  usuario_id    INT UNSIGNED NULL,
  acao          VARCHAR(40)  NOT NULL,
  detalhe       TEXT         NULL,
  quando        DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY fin_eventos_lanc (lancamento_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_duplicados_ok (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  lancamento_a INT UNSIGNED NOT NULL,
  lancamento_b INT UNSIGNED NOT NULL,
  usuario_id   INT UNSIGNED NULL,
  quando       DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_dupok_par (lancamento_a, lancamento_b),
  KEY fin_dupok_b (lancamento_b)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_contas_fixas (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome            VARCHAR(120) NOT NULL,
  tipo            VARCHAR(30)  NOT NULL DEFAULT 'Serviço contratado',
  fornecedor      VARCHAR(140) NULL,
  categoria_id    INT UNSIGNED NULL,
  conta_id        INT UNSIGNED NULL,
  forma_pagamento VARCHAR(60)  NULL,
  valor_centavos  BIGINT       NULL,
  dia_vencimento  TINYINT UNSIGNED NOT NULL,
  periodicidade   VARCHAR(12)  NOT NULL DEFAULT 'mensal',
  mes_inicio      CHAR(7)      NOT NULL,
  mes_fim         CHAR(7)      NULL,
  aviso_dias      TINYINT UNSIGNED NOT NULL DEFAULT 5,
  importante      TINYINT(1)   NOT NULL DEFAULT 0,
  observacao      TEXT         NULL,
  ativa           TINYINT(1)   NOT NULL DEFAULT 1,
  usuario_id      INT UNSIGNED NULL,
  criado_em       DATETIME     NOT NULL,
  atualizado_em   DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY fin_cfixa_ativa (ativa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_contas_fixas_meses (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta_fixa_id  INT UNSIGNED NOT NULL,
  competencia    CHAR(7)      NOT NULL,
  situacao       VARCHAR(12)  NOT NULL DEFAULT 'lancada',
  lancamento_id  INT UNSIGNED NULL,
  boleto_path    VARCHAR(255) NULL,
  observacao     VARCHAR(255) NULL,
  usuario_id     INT UNSIGNED NULL,
  quando         DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_cfm_lanc (lancamento_id),
  KEY fin_cfm_mes (conta_fixa_id, competencia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_producao_meses (
  id                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  competencia         CHAR(7)      NOT NULL,
  dias_uteis          TINYINT UNSIGNED NOT NULL,
  tarifa_vt_centavos  INT          NOT NULL,
  lanche_dia_centavos INT          NOT NULL,
  situacao            VARCHAR(10)  NOT NULL DEFAULT 'aberta',
  origem              VARCHAR(10)  NOT NULL DEFAULT 'sistema',
  formato             VARCHAR(10)  NOT NULL DEFAULT 'resumida',
  aba_planilha        VARCHAR(60)  NULL,
  notas_colunas       TEXT         NULL,
  anotacoes           MEDIUMTEXT   NULL,
  observacao          TEXT         NULL,
  usuario_id          INT UNSIGNED NULL,
  criado_em           DATETIME     NOT NULL,
  atualizado_em       DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_prod_mes (competencia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_producao_linhas (
  id                    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  mes_id                INT UNSIGNED NOT NULL,
  ordem                 SMALLINT     NOT NULL DEFAULT 0,
  colaborador_chave     VARCHAR(140) NULL,
  nome                  VARCHAR(140) NOT NULL,
  funcao                VARCHAR(80)  NULL,
  medicao_expr          VARCHAR(255) NULL,
  salario_expr          VARCHAR(255) NULL,
  adiant2_expr          VARCHAR(255) NULL,
  adiant3_expr          VARCHAR(255) NULL,
  descontos_expr        VARCHAR(255) NULL,
  faltas_expr           VARCHAR(255) NULL,
  vt_expr               VARCHAR(255) NULL,
  lanche_expr           VARCHAR(255) NULL,
  dias_falta            TINYINT UNSIGNED NOT NULL DEFAULT 0,
  total_expr            VARCHAR(255) NULL,
  total_centavos        BIGINT       NOT NULL DEFAULT 0,
  observacao            VARCHAR(255) NULL,
  notas                 TEXT         NULL,
  planilha              MEDIUMTEXT   NULL,
  total_planilha        BIGINT       NULL,
  lancamento_id         INT UNSIGNED NULL,
  lancado_centavos      BIGINT       NULL,
  pagamento             VARCHAR(10)  NULL,
  atualizado_em         DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY fin_prod_linha_mes (mes_id, ordem),
  KEY fin_prod_linha_lanc (lancamento_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_contas_bancarias (
  id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome                   VARCHAR(80)  NOT NULL,
  conta_id               INT UNSIGNED NULL,
  banco                  VARCHAR(60)  NULL,
  banco_codigo           VARCHAR(10)  NULL,
  agencia                VARCHAR(20)  NULL,
  final_conta            VARCHAR(12)  NULL,
  ofx_chave              CHAR(64)     NULL,
  saldo_inicial_centavos BIGINT       NULL,
  data_saldo_inicial     DATE         NULL,
  ativa                  TINYINT(1)   NOT NULL DEFAULT 1,
  criado_em              DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_cb_nome (nome),
  UNIQUE KEY fin_cb_ofx (ofx_chave),
  CONSTRAINT fk_fin_cb_conta FOREIGN KEY (conta_id) REFERENCES fin_contas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_importacoes (
  id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta_bancaria_id      INT UNSIGNED NOT NULL,
  formato                VARCHAR(10)  NOT NULL,
  nome_original          VARCHAR(255) NOT NULL,
  sha256                 CHAR(64)     NOT NULL,
  sha_ativo              CHAR(64)     NULL,
  tamanho                INT UNSIGNED NOT NULL DEFAULT 0,
  periodo_ini            DATE         NULL,
  periodo_fim            DATE         NULL,
  saldo_inicial_centavos BIGINT       NULL,
  saldo_final_centavos   BIGINT       NULL,
  data_saldo_final       DATE         NULL,
  linhas_lidas           INT UNSIGNED NOT NULL DEFAULT 0,
  transacoes_novas       INT UNSIGNED NOT NULL DEFAULT 0,
  transacoes_repetidas   INT UNSIGNED NOT NULL DEFAULT 0,
  transacoes_suspeitas   INT UNSIGNED NOT NULL DEFAULT 0,
  status                 VARCHAR(10)  NOT NULL DEFAULT 'gravada',
  usuario_id             INT UNSIGNED NULL,
  criado_em              DATETIME     NOT NULL,
  desfeita_em            DATETIME     NULL,
  resumo                 MEDIUMTEXT   NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_imp_arquivo (conta_bancaria_id, sha_ativo),
  KEY fin_imp_periodo (conta_bancaria_id, periodo_ini, periodo_fim),
  CONSTRAINT fk_fin_imp_conta FOREIGN KEY (conta_bancaria_id) REFERENCES fin_contas_bancarias(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_transacoes (
  id                     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta_bancaria_id      INT UNSIGNED NOT NULL,
  primeira_importacao_id INT UNSIGNED NOT NULL,
  data                   DATE         NOT NULL,
  valor_centavos         BIGINT       NOT NULL,
  memo_original          VARCHAR(255) NOT NULL,
  memo_normalizado       VARCHAR(255) NOT NULL,
  documento              VARCHAR(80)  NULL,
  fitid                  VARCHAR(80)  NULL,
  saldo_apos_centavos    BIGINT       NULL,
  ordinal                SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  chave_dedup            CHAR(64)     NOT NULL,
  situacao               VARCHAR(12)  NOT NULL DEFAULT 'aberta',
  suspeita_de            BIGINT UNSIGNED NULL,
  criado_em              DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_trans_chave (conta_bancaria_id, chave_dedup),
  KEY fin_trans_dia (conta_bancaria_id, data),
  KEY fin_trans_valor (valor_centavos, data),
  KEY fin_trans_situacao (situacao),
  KEY fin_trans_imp (primeira_importacao_id),
  CONSTRAINT fk_fin_trans_conta FOREIGN KEY (conta_bancaria_id) REFERENCES fin_contas_bancarias(id),
  CONSTRAINT fk_fin_trans_imp FOREIGN KEY (primeira_importacao_id) REFERENCES fin_importacoes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_transacoes_origem (
  importacao_id          INT UNSIGNED    NOT NULL,
  transacao_id           BIGINT UNSIGNED NOT NULL,
  linha                  INT UNSIGNED    NOT NULL DEFAULT 0,
  PRIMARY KEY (importacao_id, transacao_id),
  KEY fin_tor_transacao (transacao_id),
  CONSTRAINT fk_fin_tor_imp FOREIGN KEY (importacao_id) REFERENCES fin_importacoes(id),
  CONSTRAINT fk_fin_tor_trans FOREIGN KEY (transacao_id) REFERENCES fin_transacoes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_conciliacoes (
  id                     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  origem                 VARCHAR(10)  NOT NULL DEFAULT 'manual',
  regra                  VARCHAR(20)  NULL,
  regra_versao           VARCHAR(12)  NULL,
  pontos                 INT          NULL,
  status_antes           VARCHAR(30)  NULL,
  pagamento_antes        DATE         NULL,
  conta_antes            INT UNSIGNED NULL,
  diferenca_centavos     BIGINT       NOT NULL DEFAULT 0,
  justificativa          VARCHAR(255) NULL,
  status                 VARCHAR(10)  NOT NULL DEFAULT 'ativa',
  usuario_id             INT UNSIGNED NULL,
  quando                 DATETIME     NOT NULL,
  desfeita_por           INT UNSIGNED NULL,
  desfeita_em            DATETIME     NULL,
  PRIMARY KEY (id),
  KEY fin_conc_status (status, quando)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_conciliacao_itens (
  id                     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conciliacao_id         BIGINT UNSIGNED NOT NULL,
  transacao_id           BIGINT UNSIGNED NOT NULL,
  lancamento_id          INT UNSIGNED    NOT NULL,
  valor_alocado_centavos BIGINT          NOT NULL,
  ativo_transacao        BIGINT UNSIGNED NULL,
  ativo_lancamento       INT UNSIGNED    NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_ci_transacao (ativo_transacao),
  UNIQUE KEY fin_ci_lancamento (ativo_lancamento),
  KEY fin_ci_conciliacao (conciliacao_id),
  KEY fin_ci_trans (transacao_id),
  KEY fin_ci_lanc (lancamento_id),
  CONSTRAINT fk_fin_ci_conc FOREIGN KEY (conciliacao_id) REFERENCES fin_conciliacoes(id),
  CONSTRAINT fk_fin_ci_trans FOREIGN KEY (transacao_id) REFERENCES fin_transacoes(id),
  CONSTRAINT fk_fin_ci_lanc FOREIGN KEY (lancamento_id) REFERENCES fin_lancamentos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_sugestoes (
  id                     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  transacao_id           BIGINT UNSIGNED NOT NULL,
  lancamento_id          INT UNSIGNED    NOT NULL,
  regra                  VARCHAR(20)  NOT NULL,
  regra_versao           VARCHAR(12)  NOT NULL,
  pontos                 INT          NOT NULL,
  forca                  VARCHAR(8)   NOT NULL,
  motivos                TEXT         NULL,
  situacao               VARCHAR(10)  NOT NULL DEFAULT 'aberta',
  gerada_em              DATETIME     NOT NULL,
  atualizada_em          DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_sug_par (transacao_id, lancamento_id, regra_versao),
  KEY fin_sug_situacao (situacao, forca),
  KEY fin_sug_lanc (lancamento_id),
  CONSTRAINT fk_fin_sug_trans FOREIGN KEY (transacao_id) REFERENCES fin_transacoes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_sugestoes_rejeitadas (
  transacao_id           BIGINT UNSIGNED NOT NULL,
  lancamento_id          INT UNSIGNED    NOT NULL,
  usuario_id             INT UNSIGNED    NULL,
  quando                 DATETIME        NOT NULL,
  PRIMARY KEY (transacao_id, lancamento_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_conc_aprendido (
  id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  chave                  VARCHAR(120) NOT NULL,
  tipo                   VARCHAR(7)   NOT NULL,
  fornecedor_id          INT UNSIGNED NOT NULL DEFAULT 0,
  categoria_id           INT UNSIGNED NOT NULL DEFAULT 0,
  vezes                  INT UNSIGNED NOT NULL DEFAULT 1,
  ultima_em              DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_aprend_chave (chave, tipo, fornecedor_id, categoria_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_fechamentos (
  id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta_bancaria_id      INT UNSIGNED NOT NULL,
  competencia            CHAR(7)      NOT NULL,
  snapshot               MEDIUMTEXT   NOT NULL,
  hash                   CHAR(64)     NOT NULL,
  vigente                TINYINT      NULL,
  usuario_id             INT UNSIGNED NULL,
  quando                 DATETIME     NOT NULL,
  reaberto_por           INT UNSIGNED NULL,
  reaberto_em            DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_fech_vigente (conta_bancaria_id, competencia, vigente),
  CONSTRAINT fk_fin_fech_conta FOREIGN KEY (conta_bancaria_id) REFERENCES fin_contas_bancarias(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW fin_v_lancamentos AS
SELECT l.*,
       c.nome  AS categoria,  c.grupo AS grupo,
       f.nome  AS fornecedor, ct.nome AS conta,
       tv.nome AS tipo_venda, so.nome AS status_obra, cs.nome AS consultor,
       CASE WHEN l.status IN ('Pendente','Agendado','Aguardando conferencia')
             AND l.data_vencimento < CURDATE()
            THEN 1 ELSE 0 END AS vencido
FROM fin_lancamentos l
LEFT JOIN fin_categorias   c  ON c.id  = l.categoria_id
LEFT JOIN fin_fornecedores f  ON f.id  = l.fornecedor_id
LEFT JOIN fin_contas       ct ON ct.id = l.conta_id
LEFT JOIN fin_tipos_venda  tv ON tv.id = l.tipo_venda_id
LEFT JOIN fin_status_obra  so ON so.id = l.status_obra_id
LEFT JOIN fin_consultores  cs ON cs.id = l.consultor_id;

CREATE TABLE IF NOT EXISTS scanner_lotes (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id    INT UNSIGNED NULL,
  quando        DATETIME     NOT NULL,
  maquina       VARCHAR(80)  NULL,
  arquivos      TEXT         NULL,
  pasta_saida   VARCHAR(255) NULL,
  paginas       INT NOT NULL DEFAULT 0,
  ok            INT NOT NULL DEFAULT 0,
  revisar       INT NOT NULL DEFAULT 0,
  erro          INT NOT NULL DEFAULT 0,
  competencia   VARCHAR(7)   NULL,
  motivos       TEXT         NULL,
  relatorio_csv VARCHAR(255) NULL,
  PRIMARY KEY (id),
  KEY scanner_lotes_quando (quando)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS scanner_paginas (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  lote_id      INT UNSIGNED NOT NULL,
  pagina       INT          NOT NULL,
  categoria    VARCHAR(40)  NULL,
  colaborador  VARCHAR(140) NULL,
  nome_lido    VARCHAR(140) NULL,
  competencia  VARCHAR(7)   NULL,
  status       VARCHAR(12)  NULL,
  arquivo      VARCHAR(255) NULL,
  motivo       VARCHAR(255) NULL,
  cadastro     VARCHAR(255) NULL,
  PRIMARY KEY (id),
  KEY scanner_paginas_lote (lote_id),
  CONSTRAINT fk_scanner_paginas_lote FOREIGN KEY (lote_id) REFERENCES scanner_lotes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS servicos_projetos (
  id         INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  impressao  CHAR(64)          NOT NULL,
  arquivo    VARCHAR(255)      NOT NULL,
  paginas    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  lidos      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  lido_em    DATETIME          NOT NULL,
  usado_em   DATETIME          NULL,
  usuario_id INT UNSIGNED      NULL,
  PRIMARY KEY (id),
  UNIQUE KEY servicos_proj_impressao (impressao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS servicos_licoes (
  id          INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  projeto_id  INT UNSIGNED      NOT NULL,
  local       VARCHAR(120)      NOT NULL,
  pagina      SMALLINT UNSIGNED NULL,
  confianca   VARCHAR(6)        NULL,
  lado1_lido  DECIMAL(8,2)      NULL,
  lado2_lido  DECIMAL(8,2)      NULL,
  area_lida   DECIMAL(10,2)     NULL,
  lado1       DECIMAL(8,2)      NOT NULL,
  lado2       DECIMAL(8,2)      NOT NULL,
  area        DECIMAL(10,2)     NULL,
  corrigido   TINYINT(1)        NOT NULL DEFAULT 0,
  quando      DATETIME          NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY servicos_licao_amb (projeto_id, local),
  KEY servicos_licao_local (local),
  CONSTRAINT fk_servicos_licoes_projeto FOREIGN KEY (projeto_id) REFERENCES servicos_projetos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS servicos_vocabulario (
  palavra   VARCHAR(60)  NOT NULL,
  vezes     INT UNSIGNED NOT NULL DEFAULT 1,
  criado_em DATETIME     NOT NULL,
  PRIMARY KEY (palavra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS servicos_estudo (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  chave       CHAR(64)      NOT NULL,
  origem      VARCHAR(12)   NOT NULL,
  situacao    VARCHAR(10)   NOT NULL DEFAULT 'feito',
  referencia  VARCHAR(160)  NOT NULL DEFAULT '',
  data        DATE          NOT NULL,
  projeto_id  INT UNSIGNED  NULL,
  linhas      MEDIUMTEXT    NOT NULL,
  quantidades TEXT          NOT NULL,
  parametros  TEXT          NOT NULL,
  calculado   INT           NULL,
  enviado     INT           NOT NULL,
  escopo      TEXT          NOT NULL,
  observacao  VARCHAR(500)  NOT NULL DEFAULT '',
  tela        MEDIUMTEXT    NULL,
  criado_em   DATETIME      NOT NULL,
  usuario_id  INT UNSIGNED  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY servicos_estudo_chave (chave),
  KEY servicos_estudo_data (data)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS site_orcamentos (
  id            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  protocolo     VARCHAR(20)   NOT NULL,
  nome          VARCHAR(120)  NOT NULL,
  email         VARCHAR(160)  NOT NULL DEFAULT '',
  telefone      VARCHAR(20)   NOT NULL DEFAULT '',
  funcao        VARCHAR(20)   NOT NULL,
  arquivo       VARCHAR(160)  NOT NULL DEFAULT '',
  paginas       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  ambientes     MEDIUMTEXT    NOT NULL,
  area_m2       DECIMAL(9,2)  NOT NULL DEFAULT 0,
  valor_centavos INT          NULL,
  faixa_min     INT           NULL,
  faixa_max     INT           NULL,
  situacao      VARCHAR(20)   NOT NULL DEFAULT 'novo',
  observacao    VARCHAR(500)  NOT NULL DEFAULT '',
  ip_hash       CHAR(64)      NOT NULL,
  consentiu_em  DATETIME      NOT NULL,
  criado_em     DATETIME      NOT NULL,
  atualizado_em DATETIME      NULL,
  usuario_id    INT UNSIGNED  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY site_orcamentos_protocolo (protocolo),
  KEY site_orcamentos_situacao (situacao, criado_em),
  KEY site_orcamentos_ip (ip_hash, criado_em)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_obras (
  id                      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome                    VARCHAR(160) NOT NULL,
  cliente                 VARCHAR(160) NOT NULL,
  cliente_tipo            VARCHAR(20)  NOT NULL DEFAULT 'Construtora',
  documento               VARCHAR(20)  NULL,
  cidade                  VARCHAR(80)  NULL,
  situacao                VARCHAR(20)  NOT NULL DEFAULT 'Em andamento',
  valor_contrato_centavos BIGINT       NULL,
  inicio                  DATE         NULL,
  fim                     DATE         NULL,
  observacao              TEXT         NULL,
  usuario_id              INT UNSIGNED NULL,
  criado_em               DATETIME     NOT NULL,
  atualizado_em           DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_obras_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_documentos (
  id                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo                VARCHAR(10)  NOT NULL,
  obra_id             INT UNSIGNED NULL,
  cliente             VARCHAR(160) NOT NULL,
  cliente_tipo        VARCHAR(20)  NOT NULL DEFAULT 'Construtora',
  numero              VARCHAR(40)  NULL,
  emitente_cnpj       VARCHAR(14)  NULL,
  tomador_documento   VARCHAR(14)  NULL,
  data_emissao        DATE         NOT NULL,
  periodo_inicio      DATE         NULL,
  periodo_fim         DATE         NULL,
  valor_centavos      BIGINT       NOT NULL DEFAULT 0,
  retencoes_centavos  BIGINT       NOT NULL DEFAULT 0,
  vencimento          DATE         NULL,
  situacao            VARCHAR(24)  NOT NULL,
  conferencia         VARCHAR(12)  NOT NULL DEFAULT 'conferida',
  conferido_em        DATETIME     NULL,
  conferido_por       INT UNSIGNED NULL,
  pago_em             DATE         NULL,
  medicao_id          INT UNSIGNED NULL,
  lancamento_id       INT UNSIGNED NULL,
  descricao           VARCHAR(255) NULL,
  observacao          TEXT         NULL,
  usuario_id          INT UNSIGNED NULL,
  criado_em           DATETIME     NOT NULL,
  atualizado_em       DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY srv_doc_tipo (tipo, data_emissao),
  KEY srv_doc_obra (obra_id),
  KEY srv_doc_medicao (medicao_id),
  KEY srv_doc_lanc (lancamento_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_anexos (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  documento_id  INT UNSIGNED NOT NULL,
  caminho       VARCHAR(255) NOT NULL,
  nome          VARCHAR(255) NOT NULL,
  hash          CHAR(64)     NOT NULL,
  tamanho       INT UNSIGNED NOT NULL DEFAULT 0,
  usuario_id    INT UNSIGNED NULL,
  criado_em     DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY srv_anexos_doc (documento_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_doc_historico (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  documento_id  INT UNSIGNED NOT NULL,
  quando        DATETIME     NOT NULL,
  usuario_id    INT UNSIGNED NULL,
  evento        VARCHAR(24)  NOT NULL,
  texto         VARCHAR(255) NOT NULL,
  dados         MEDIUMTEXT   NULL,
  PRIMARY KEY (id),
  KEY srv_doc_hist (documento_id, quando)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_caixa_emails (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta           VARCHAR(60)  NOT NULL,
  pasta           VARCHAR(120) NOT NULL,
  uidvalidity     BIGINT UNSIGNED NOT NULL,
  uid             BIGINT UNSIGNED NOT NULL,
  message_id      VARCHAR(255) NULL,
  remetente_nome  VARCHAR(200) NULL,
  remetente_email VARCHAR(190) NULL,
  assunto         VARCHAR(500) NULL,
  recebido_em     DATETIME     NULL,
  trecho          TEXT         NULL,
  links           TEXT         NULL,
  linhas_corpo    TEXT         NULL,
  avisos          TEXT         NULL,
  tem_anexo       TINYINT(1)   NOT NULL DEFAULT 0,
  estado          VARCHAR(12)  NOT NULL DEFAULT 'novo',
  decidido_em     DATETIME     NULL,
  decidido_por    INT UNSIGNED NULL,
  coletado_em     DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_cx_email_uid (conta, pasta, uidvalidity, uid),
  KEY fin_cx_email_data (recebido_em),
  KEY fin_cx_email_msg (message_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_caixa_anexos (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  email_id      INT UNSIGNED NOT NULL,
  nome          VARCHAR(200) NOT NULL,
  extensao      VARCHAR(8)   NOT NULL,
  tamanho       INT UNSIGNED NOT NULL,
  sha256        CHAR(64)     NOT NULL,
  caminho       VARCHAR(255) NOT NULL,
  tipo          VARCHAR(12)  NOT NULL DEFAULT 'a_ler',
  leitura       TEXT         NULL,
  lido_em       DATETIME     NULL,
  estado        VARCHAR(12)  NOT NULL DEFAULT 'novo',
  lancamento_id INT UNSIGNED NULL,
  repetido_de   INT UNSIGNED NULL,
  motivo        VARCHAR(255) NULL,
  decidido_em   DATETIME     NULL,
  decidido_por  INT UNSIGNED NULL,
  criado_em     DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY fin_cx_anexo_email (email_id),
  KEY fin_cx_anexo_sha (sha256),
  KEY fin_cx_anexo_estado (estado),
  CONSTRAINT fk_fin_cx_anexo_email FOREIGN KEY (email_id) REFERENCES fin_caixa_emails(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_caixa_coletas (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta        VARCHAR(60)  NOT NULL,
  iniciou_em   DATETIME     NOT NULL,
  terminou_em  DATETIME     NULL,
  ok           TINYINT(1)   NOT NULL DEFAULT 1,
  erro         VARCHAR(500) NULL,
  vistos       INT UNSIGNED NOT NULL DEFAULT 0,
  guardados    INT UNSIGNED NOT NULL DEFAULT 0,
  ignorados    INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY fin_cx_coleta_conta (conta, terminou_em)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_caixa_checagens (
  fonte       VARCHAR(80)  NOT NULL,
  dia         DATE         NOT NULL,
  usuario_id  INT UNSIGNED NULL,
  criado_em   DATETIME     NOT NULL,
  PRIMARY KEY (fonte, dia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_caixa_nao_casa (
  anexo_id       INT UNSIGNED NOT NULL,
  lancamento_id  INT UNSIGNED NOT NULL,
  usuario_id     INT UNSIGNED NULL,
  criado_em      DATETIME     NOT NULL,
  PRIMARY KEY (anexo_id, lancamento_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fin_notas_material (
  identidade     VARCHAR(90)  NOT NULL,
  estado         VARCHAR(12)  NOT NULL,
  lancamento_id  INT UNSIGNED NULL,
  observacao     VARCHAR(300) NULL,
  usuario_id     INT UNSIGNED NULL,
  criado_em      DATETIME     NOT NULL,
  PRIMARY KEY (identidade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_materiais (
  id                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo             VARCHAR(30)  NOT NULL,
  nome               VARCHAR(120) NOT NULL,
  categoria          VARCHAR(20)  NOT NULL DEFAULT 'outro',
  unidade            VARCHAR(12)  NOT NULL,
  unidade_compra     VARCHAR(30)  NOT NULL,
  rendimento         DOUBLE       NOT NULL DEFAULT 1,
  fornecedor_padrao  VARCHAR(60)  NULL,
  chave_levantamento VARCHAR(20)  NULL,
  ativo              TINYINT(1)   NOT NULL DEFAULT 1,
  observacao         VARCHAR(255) NULL,
  atualizado_em      DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_mat_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_material_precos (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  material_id    INT UNSIGNED NOT NULL,
  fornecedor     VARCHAR(60)  NOT NULL,
  preco          INT          NOT NULL,
  vigente_desde  DATE         NOT NULL,
  observacao     VARCHAR(255) NULL,
  usuario_id     INT UNSIGNED NULL,
  criado_em      DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_matpreco_chave (material_id, fornecedor, vigente_desde),
  KEY srv_matpreco_mat (material_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_servicos (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo         VARCHAR(20)  NOT NULL,
  familia        VARCHAR(12)  NOT NULL,
  nome           VARCHAR(160) NOT NULL,
  unidade        VARCHAR(6)   NOT NULL,
  sigla          VARCHAR(6)   NOT NULL DEFAULT '',
  texto          VARCHAR(255) NOT NULL,
  especificacao  TEXT         NULL,
  tecnico        VARCHAR(120) NULL,
  mao_de_obra    INT          NULL,
  ordem          INT          NOT NULL DEFAULT 0,
  ativo          TINYINT(1)   NOT NULL DEFAULT 1,
  atualizado_em  DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_serv_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_composicoes (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  servico_id   INT UNSIGNED NOT NULL,
  material_id  INT UNSIGNED NOT NULL,
  consumo      DOUBLE       NOT NULL,
  ordem        INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY srv_comp_chave (servico_id, material_id),
  KEY srv_comp_mat (material_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_tabelas (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo         VARCHAR(20)  NOT NULL,
  nome           VARCHAR(80)  NOT NULL,
  porte          VARCHAR(10)  NOT NULL DEFAULT 'pequeno',
  descricao      VARCHAR(255) NULL,
  ordem          INT          NOT NULL DEFAULT 0,
  ativo          TINYINT(1)   NOT NULL DEFAULT 1,
  atualizado_em  DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_tab_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_tabela_precos (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tabela_id      INT UNSIGNED NOT NULL,
  servico_id     INT UNSIGNED NOT NULL,
  preco          INT          NULL,
  vigente_desde  DATE         NOT NULL,
  observacao     VARCHAR(255) NULL,
  usuario_id     INT UNSIGNED NULL,
  criado_em      DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_tabpreco_chave (tabela_id, servico_id, vigente_desde),
  KEY srv_tabpreco_serv (servico_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_espelho (
  tabela      VARCHAR(30)  NOT NULL,
  chave       VARCHAR(120) NOT NULL,
  criado_em   DATETIME     NOT NULL,
  tentativas  INT UNSIGNED NOT NULL DEFAULT 0,
  erro        VARCHAR(255) NULL,
  PRIMARY KEY (tabela, chave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_med_servicos (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo        VARCHAR(20)  NOT NULL,
  nome          VARCHAR(120) NOT NULL,
  unidade       VARCHAR(4)   NOT NULL,
  regra         VARCHAR(255) NULL,
  mo_min        INT          NULL,
  mo_max        INT          NULL,
  mat_min       INT          NULL,
  mat_max       INT          NULL,
  mo_fixo       INT          NULL,
  servico_venda    VARCHAR(20) NULL,
  mo_da_composicao TINYINT(1)  NOT NULL DEFAULT 0,
  ativo         TINYINT(1)   NOT NULL DEFAULT 1,
  ordem         SMALLINT     NOT NULL DEFAULT 0,
  atualizado_em DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_medserv_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_med_medicoes (
  id                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  competencia       CHAR(7)      NOT NULL,
  nome              VARCHAR(140) NOT NULL,
  faixa             CHAR(3)      NOT NULL DEFAULT 'med',
  tabela_venda      VARCHAR(20)  NOT NULL DEFAULT 'PEQUENO',
  texto             MEDIUMTEXT   NULL,
  origem            VARCHAR(10)  NOT NULL DEFAULT 'texto',
  arquivo           VARCHAR(190) NULL,
  observacao        VARCHAR(255) NULL,
  tabela            MEDIUMTEXT   NULL,
  total_mo          BIGINT       NOT NULL DEFAULT 0,
  total_mat         BIGINT       NOT NULL DEFAULT 0,
  levado_em         DATETIME     NULL,
  levado_centavos   BIGINT       NULL,
  usuario_id        INT UNSIGNED NULL,
  criado_em         DATETIME     NOT NULL,
  atualizado_em     DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_med_mes_nome (competencia, nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS srv_med_itens (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  medicao_id  INT UNSIGNED NOT NULL,
  ordem       SMALLINT     NOT NULL DEFAULT 0,
  obra        VARCHAR(140) NULL,
  local_txt   VARCHAR(140) NULL,
  descricao   VARCHAR(400) NOT NULL,
  original    VARCHAR(500) NULL,
  servico     VARCHAR(20)  NULL,
  contagem    INT          NOT NULL DEFAULT 1,
  medidas     VARCHAR(255) NULL,
  qtd_mil     BIGINT       NULL,
  qtd_manual  TINYINT(1)   NOT NULL DEFAULT 0,
  conferido   TINYINT(1)   NOT NULL DEFAULT 0,
  preco_mo    INT          NULL,
  aviso       VARCHAR(400) NULL,
  confianca   VARCHAR(8)   NOT NULL DEFAULT 'alta',
  PRIMARY KEY (id),
  KEY srv_meditem_med (medicao_id, ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
