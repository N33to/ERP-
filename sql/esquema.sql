-- Esquema do ERP (MySQL 5.7/8.0, MariaDB 10.4+) — SOMENTE ESTRUTURA, sem dados.
-- (api_operacoes, login_confiavel, login_desafios, mfa_recuperacao, sessoes, sessoes_encerradas, tentativas_login, tickets_download)

-- ERP — esquema MySQL (compatível com MySQL 5.7 e 8.0, MariaDB 10.4+).
--
-- Decisões que valem para o arquivo inteiro:
--   * utf8mb4: nomes com acento e o "Ç" do cadastro do RH.
--   * Datas em DATE, competência em CHAR(7) 'AAAA-MM' (ordena sozinha).
--   * Dinheiro do financeiro em INTEGER de centavos (regra herdada do módulo Financeiro);
--     salário do RH em DECIMAL(12,2) porque ele entra em conta com divisor e multiplicador.
--   * Nada de CHECK: o MySQL 5.7 ignora CHECK em silêncio — a validação mora no PHP.
--   * Sem DELETE em cascata nas tabelas de negócio: quem apaga é a regra, com registro.

SET NAMES utf8mb4;
SET time_zone = '-03:00';

-- ─────────────────────────────── acesso ────────────────────────────────

CREATE TABLE IF NOT EXISTS perfis (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome        VARCHAR(60)  NOT NULL,
  descricao   VARCHAR(200) NOT NULL DEFAULT '',
  admin       TINYINT(1)   NOT NULL DEFAULT 0,   -- acesso total + painel de acessos
  fixo        TINYINT(1)   NOT NULL DEFAULT 0,   -- 'Sócio (admin)' não pode ser apagado
  ordem       INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY perfis_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Uma linha por (perfil, módulo). Nível: 'nenhum' | 'ver' | 'editar'.
-- Módulo sem linha = 'nenhum'. Perfil admin ignora esta tabela.
CREATE TABLE IF NOT EXISTS perfil_modulos (
  perfil_id   INT UNSIGNED NOT NULL,
  modulo      VARCHAR(40)  NOT NULL,
  nivel       VARCHAR(10)  NOT NULL DEFAULT 'nenhum',
  PRIMARY KEY (perfil_id, modulo),
  CONSTRAINT fk_perfil_modulos_perfil FOREIGN KEY (perfil_id) REFERENCES perfis(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- O que um perfil NÃO vê dentro de um módulo que ele enxerga (01/10/2026):
-- sub-tela, campo, seção ou ação — o catálogo é `Acesso::RECURSOS`. Sem linha
-- = vê; por isso perfil antigo e recurso novo nascem liberados.
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
  trocar_senha  TINYINT(1)   NOT NULL DEFAULT 0,  -- obriga a trocar no próximo login
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
  alvo        VARCHAR(80)  NULL,                  -- o que foi atingido: usuario#12, perfil#3, lancamento#40…
  resultado   VARCHAR(12)  NULL,                  -- ok | negado | falhou
  origem      VARCHAR(12)  NULL,                  -- web | api | coletor | ticket | cli
  ip          VARCHAR(45)  NULL,
  PRIMARY KEY (id),
  KEY auditoria_quando (quando),
  KEY auditoria_modulo (modulo, quando)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Configurações editáveis pelo painel (chave -> valor).
CREATE TABLE IF NOT EXISTS ajustes (
  chave  VARCHAR(60)  NOT NULL,
  valor  TEXT         NULL,
  PRIMARY KEY (chave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ──────────────────────────── cadastro (RH) ────────────────────────────
-- Substitui o "planilha de RH". As 13 colunas da planilha mãe
-- viraram colunas; `chave` é o CPF só com dígitos (ou 'NOME:<nome>' para
-- quem ainda não tem CPF) — a mesma chave que o ponto sempre usou.

CREATE TABLE IF NOT EXISTS colaboradores (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_planilha     BIGINT       NULL,               -- ID_Colaborador da planilha mãe
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
  origem          VARCHAR(20)  NOT NULL DEFAULT 'tela',   -- tela | planilha | scanner
  criado_em       DATETIME     NOT NULL,
  atualizado_em   DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY colaboradores_chave (chave),
  KEY colaboradores_cpf (cpf_digitos),
  KEY colaboradores_nome (nome_normalizado),
  KEY colaboradores_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Datas dos certificados de NR (20/10/2026). O link do certificado mora no Supabase
-- (DocumentosDrive) e lá não há data; a data mora aqui, junto do ASO e da admissão,
-- porque é daqui que o hall e a lista de colaboradores tiram os avisos de prazo.
-- `documento` é a coluna do Supabase (nr06, nr12, nr18, nr35). Sem chave estrangeira,
-- de propósito: a tabela nunca barra nada no cadastro.
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
  socios                    TEXT         NULL,    -- JSON: [[nome, qualificacao], ...]
  qualificacao_responsavel  VARCHAR(60)  NULL,
  ordem                     INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY empresas_cnpj (cnpj_digitos)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────── ponto ─────────────────────────────────
-- Cópia fiel do ponto.db (SQLite) do sistema de ponto, tabela a tabela.

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
  admissao      VARCHAR(10)  NULL,      -- dd/mm/aaaa, como o cartão imprime
  origem        VARCHAR(80)  NULL,      -- 'digitado' ou o nome da planilha importada
  atualizado_em DATETIME     NULL,
  PRIMARY KEY (colaborador, competencia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ponto_dia (
  colaborador    VARCHAR(140) NOT NULL,
  data           DATE         NOT NULL,
  manha_entrada  SMALLINT     NULL,     -- minutos desde a meia-noite
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

-- ────────────────────────────── termos ─────────────────────────────────

CREATE TABLE IF NOT EXISTS termos_gerados (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id   INT UNSIGNED NULL,
  quando       DATETIME     NOT NULL,
  tipo         VARCHAR(20)  NOT NULL,
  competencia  CHAR(7)      NOT NULL,
  rotulo       VARCHAR(10)  NOT NULL,        -- ago-26
  data_termo   VARCHAR(10)  NOT NULL,
  colaborador  VARCHAR(140) NOT NULL,        -- chave
  nome         VARCHAR(140) NOT NULL,
  arquivo_pdf  VARCHAR(255) NULL,            -- relativo a dados/termos
  arquivo_docx VARCHAR(255) NULL,
  PRIMARY KEY (id),
  KEY termos_comp (competencia, tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ──────────────────────────── financeiro ───────────────────────────────
-- Cópia do esquema v3 do financeiro.db, com prefixo fin_.

CREATE TABLE IF NOT EXISTS fin_categorias (
  id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  grupo  VARCHAR(60)  NOT NULL,
  nome   VARCHAR(80)  NOT NULL,
  tipo   VARCHAR(10)  NOT NULL,            -- Entrada | Saida
  ativa  TINYINT(1)   NOT NULL DEFAULT 1,
  ordem  INT          NOT NULL DEFAULT 0,
  subgrupo VARCHAR(60) NULL,               -- organiza dentro do grupo (Custos Fixos › Pessoal); entrou em 13/11/2026
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
  tipo             VARCHAR(10)  NOT NULL,          -- Entrada | Saida
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

-- Os pares que a pessoa OLHOU e disse que não são repetição: mesmo valor, nome
-- que bate e datas vizinhas, mas pagamentos diferentes de verdade (dois fretes
-- iguais na mesma semana, a parcela que repete o valor). O botão "Duplicados"
-- da aba Lançamentos pula estes pares — não muda nada no lançamento em si, que
-- continua valendo e somando como qualquer outro. Sempre menor_id < maior_id,
-- para o mesmo par não entrar duas vezes de costas trocadas.
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

-- As contas fixas da empresa: impostos (DAS, DARF, FGTS), encargos e os serviços
-- contratados que vencem todo mês (contabilidade, medicina ocupacional,
-- telefonia). A conta fixa é o CADASTRO — o que se espera pagar e quando; o
-- dinheiro continua sendo o lançamento de sempre, ligado ao mês pela tabela
-- de baixo. Nada é apagado: conta que deixou de existir vira inativa.
CREATE TABLE IF NOT EXISTS fin_contas_fixas (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome            VARCHAR(120) NOT NULL,
  tipo            VARCHAR(30)  NOT NULL DEFAULT 'Serviço contratado',
  fornecedor      VARCHAR(140) NULL,             -- quem recebe; é por ele que se acha o lançamento do mês
  categoria_id    INT UNSIGNED NULL,
  conta_id        INT UNSIGNED NULL,
  forma_pagamento VARCHAR(60)  NULL,
  valor_centavos  BIGINT       NULL,             -- previsto; NULL = muda todo mês (imposto)
  dia_vencimento  TINYINT UNSIGNED NOT NULL,
  periodicidade   VARCHAR(12)  NOT NULL DEFAULT 'mensal',  -- mensal | bimestral | trimestral | semestral | anual
  mes_inicio      CHAR(7)      NOT NULL,         -- AAAA-MM do primeiro vencimento
  mes_fim         CHAR(7)      NULL,             -- último mês (contrato encerrado)
  aviso_dias      TINYINT UNSIGNED NOT NULL DEFAULT 5,
  importante      TINYINT(1)   NOT NULL DEFAULT 0,  -- multa/juros pesados ou risco fiscal: aparece em destaque
  observacao      TEXT         NULL,             -- portal, login, código de barras fixo, contrato
  ativa           TINYINT(1)   NOT NULL DEFAULT 1,
  usuario_id      INT UNSIGNED NULL,
  criado_em       DATETIME     NOT NULL,
  atualizado_em   DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY fin_cfixa_ativa (ativa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- O mês de cada conta fixa: qual lançamento pagou (pode ser mais de um — duas
-- guias do FGTS no mesmo mês) ou "dispensada" (não houve cobrança). Um
-- lançamento só serve a uma conta fixa. Excluir o lançamento solta o vínculo.
CREATE TABLE IF NOT EXISTS fin_contas_fixas_meses (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta_fixa_id  INT UNSIGNED NOT NULL,
  competencia    CHAR(7)      NOT NULL,          -- AAAA-MM
  situacao       VARCHAR(12)  NOT NULL DEFAULT 'lancada',   -- lancada | dispensada
  lancamento_id  INT UNSIGNED NULL,
  boleto_path    VARCHAR(255) NULL,              -- o boleto do mês, relativo a dados/anexos
  observacao     VARCHAR(255) NULL,
  usuario_id     INT UNSIGNED NULL,
  quando         DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_cfm_lanc (lancamento_id),
  KEY fin_cfm_mes (conta_fixa_id, competencia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A folha de PRODUÇÃO do mês (07/10/2026): a última aba da FOLHA MENSAL.xlsx
-- ("REF MMAAAA RESUMIDA") dentro do sistema. Cada pessoa recebe em dinheiro
--   MEDIÇÃO − SALÁRIO − ADIANT. 2 − ADIANT. 3 − DESCONTOS + FALTAS + VT + LANCHE
-- com VT = (dias úteis − dias de falta) × tarifa × 2 e LANCHE = (dias úteis −
-- dias de falta) × lanche do dia — as fórmulas da planilha. Os valores são
-- guardados como a pessoa digitou (`*_expr`, aceita conta: "114,52/4 + 744,57/6",
-- como nas células da planilha) e o total sai da conta exata, arredondado uma
-- vez só. O pagamento em dinheiro vira lançamento de saída no financeiro
-- (Salários, Dinheiro), ligado à linha por `lancamento_id`.
CREATE TABLE IF NOT EXISTS fin_producao_meses (
  id                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  competencia         CHAR(7)      NOT NULL,           -- AAAA-MM
  dias_uteis          TINYINT UNSIGNED NOT NULL,
  tarifa_vt_centavos  INT          NOT NULL,           -- a passagem (ida = volta)
  lanche_dia_centavos INT          NOT NULL,
  situacao            VARCHAR(10)  NOT NULL DEFAULT 'aberta',   -- aberta | fechada
  origem              VARCHAR(10)  NOT NULL DEFAULT 'sistema',  -- sistema | planilha (histórico importado)
  formato             VARCHAR(10)  NOT NULL DEFAULT 'resumida', -- resumida | antigo (abas antes de 07/2025: só consulta)
  aba_planilha        VARCHAR(60)  NULL,
  notas_colunas       TEXT         NULL,           -- JSON campo => explicação da coluna (os comentários do cabeçalho)
  anotacoes           MEDIUMTEXT   NULL,           -- JSON: o que a aba tinha fora da tabela (empréstimos, totais)
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
  colaborador_chave     VARCHAR(140) NULL,             -- colaboradores.chave; NULL = quem não está no cadastro
  nome                  VARCHAR(140) NOT NULL,         -- como aparece na folha
  funcao                VARCHAR(80)  NULL,
  medicao_expr          VARCHAR(255) NULL,
  salario_expr          VARCHAR(255) NULL,
  adiant2_expr          VARCHAR(255) NULL,
  adiant3_expr          VARCHAR(255) NULL,
  descontos_expr        VARCHAR(255) NULL,
  faltas_expr           VARCHAR(255) NULL,             -- FALTAS (+): o que o holerite descontou e volta aqui
  vt_expr               VARCHAR(255) NULL,             -- vazio = calculado pelos dias
  lanche_expr           VARCHAR(255) NULL,             -- vazio = calculado pelos dias
  dias_falta            TINYINT UNSIGNED NOT NULL DEFAULT 0,   -- tira dias do VT e do lanche (e a cesta)
  total_expr            VARCHAR(255) NULL,             -- valor FIXO a receber (ignora a conta): administrativo, entregador, devolução
  total_centavos        BIGINT       NOT NULL DEFAULT 0, -- T. A RECEBER $ (pode ser negativo: ficou devendo)
  observacao            VARCHAR(255) NULL,
  notas                 TEXT         NULL,             -- JSON campo => nota da célula (o comentário do Excel; aparece ao passar o mouse)
  planilha              MEDIUMTEXT   NULL,             -- JSON das colunas originais (formato antigo, só consulta)
  total_planilha        BIGINT       NULL,             -- o T. A RECEBER $ que a planilha mostrava (conferência)
  lancamento_id         INT UNSIGNED NULL,             -- a saída no financeiro (o saque é UMA saída para várias linhas)
  lancado_centavos      BIGINT       NULL,             -- o total quando foi lançado (difere = desatualizado)
  pagamento             VARCHAR(10)  NULL,             -- saque (dinheiro sacado pelo sócio) | pix (direto); NULL = lançado antes de 06/11/2026
  atualizado_em         DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY fin_prod_linha_mes (mes_id, ordem),
  KEY fin_prod_linha_lanc (lancamento_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ───────────────── conciliação bancária (14/10/2026) ─────────────────────
-- O extrato do banco é a EVIDÊNCIA; o lançamento é a OBRIGAÇÃO. As duas coisas moram
-- em tabelas separadas e a conciliação é o vínculo entre elas. Tudo aqui é novo e
-- isolado: nenhuma coluna de fin_lancamentos mudou, e com `conciliacao.ativa = false`
-- (o padrão, em app/config.php) nada disto aparece nem responde.
-- Regras do bloco:
--   * dinheiro em centavos inteiros; `valor_centavos` da transação TEM sinal (crédito +, débito −),
--     o do lançamento não (quem diz entra/sai é o `tipo`);
--   * "um vínculo ativo por lançamento/transação" é UNIQUE sobre uma coluna `ativo_*` que vale o
--     id enquanto o vínculo está ativo e NULL depois de desfeito (o MySQL aceita vários NULL e não
--     tem índice parcial); o mesmo para o SHA-256 do arquivo importado;
--   * sem trigger (a view que quebrou por DEFINER em 21/09 é o motivo) e sem CHECK: a validação mora
--     no PHP, dentro da transação, e `scripts/conciliacao_verificar.php` confere os invariantes;
--   * nada em cascata: quem apaga é a regra, com registro.

-- Cada conta do banco que manda extrato. `final_conta` guarda só o final (nunca o número inteiro);
-- `ofx_chave` é o SHA-256 de banco+agência+conta do OFX, para reconhecer o arquivo sem guardar o número.
CREATE TABLE IF NOT EXISTS fin_contas_bancarias (
  id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome                   VARCHAR(80)  NOT NULL,
  conta_id               INT UNSIGNED NULL,              -- a "conta" (nome) que os lançamentos já usam
  banco                  VARCHAR(60)  NULL,
  banco_codigo           VARCHAR(10)  NULL,
  agencia                VARCHAR(20)  NULL,
  final_conta            VARCHAR(12)  NULL,
  ofx_chave              CHAR(64)     NULL,
  saldo_inicial_centavos BIGINT       NULL,              -- o saldo antes do primeiro extrato importado
  data_saldo_inicial     DATE         NULL,
  ativa                  TINYINT(1)   NOT NULL DEFAULT 1,
  criado_em              DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_cb_nome (nome),
  UNIQUE KEY fin_cb_ofx (ofx_chave),
  CONSTRAINT fk_fin_cb_conta FOREIGN KEY (conta_id) REFERENCES fin_contas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Um arquivo de extrato que entrou. O mesmo arquivo (mesmo SHA-256) na mesma conta não entra duas
-- vezes enquanto a importação anterior estiver 'gravada'; desfeita, pode entrar de novo (`sha_ativo` NULL).
CREATE TABLE IF NOT EXISTS fin_importacoes (
  id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta_bancaria_id      INT UNSIGNED NOT NULL,
  formato                VARCHAR(10)  NOT NULL,          -- ofx | csv | xlsx | pdf
  nome_original          VARCHAR(255) NOT NULL,
  sha256                 CHAR(64)     NOT NULL,
  sha_ativo              CHAR(64)     NULL,
  tamanho                INT UNSIGNED NOT NULL DEFAULT 0,
  periodo_ini            DATE         NULL,
  periodo_fim            DATE         NULL,
  saldo_inicial_centavos BIGINT       NULL,              -- como o arquivo declara
  saldo_final_centavos   BIGINT       NULL,
  data_saldo_final       DATE         NULL,
  linhas_lidas           INT UNSIGNED NOT NULL DEFAULT 0,
  transacoes_novas       INT UNSIGNED NOT NULL DEFAULT 0,
  transacoes_repetidas   INT UNSIGNED NOT NULL DEFAULT 0,
  transacoes_suspeitas   INT UNSIGNED NOT NULL DEFAULT 0,
  status                 VARCHAR(10)  NOT NULL DEFAULT 'gravada',   -- gravada | desfeita
  usuario_id             INT UNSIGNED NULL,
  criado_em              DATETIME     NOT NULL,
  desfeita_em            DATETIME     NULL,
  resumo                 MEDIUMTEXT   NULL,              -- JSON: avisos, saldo conferido, linhas recusadas
  PRIMARY KEY (id),
  UNIQUE KEY fin_imp_arquivo (conta_bancaria_id, sha_ativo),
  KEY fin_imp_periodo (conta_bancaria_id, periodo_ini, periodo_fim),
  CONSTRAINT fk_fin_imp_conta FOREIGN KEY (conta_bancaria_id) REFERENCES fin_contas_bancarias(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Uma linha do extrato. `chave_dedup` identifica a transação entre arquivos: o FITID quando o
-- banco entrega, senão o texto normalizado, sempre com data, valor e a ordem da ocorrência no dia
-- (dois pagamentos iguais no mesmo dia são duas transações, não uma repetida).
-- `situacao`: aberta | conciliada | ignorada | suspeita (parece a mesma de outro arquivo, em outro formato).
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

-- Em quais arquivos cada transação apareceu (arquivos que se sobrepõem trazem as mesmas linhas):
-- a transação só some quando nenhuma importação ativa a contém mais.
CREATE TABLE IF NOT EXISTS fin_transacoes_origem (
  importacao_id          INT UNSIGNED    NOT NULL,
  transacao_id           BIGINT UNSIGNED NOT NULL,
  linha                  INT UNSIGNED    NOT NULL DEFAULT 0,   -- a linha no arquivo
  PRIMARY KEY (importacao_id, transacao_id),
  KEY fin_tor_transacao (transacao_id),
  CONSTRAINT fk_fin_tor_imp FOREIGN KEY (importacao_id) REFERENCES fin_importacoes(id),
  CONSTRAINT fk_fin_tor_trans FOREIGN KEY (transacao_id) REFERENCES fin_transacoes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A decisão de conciliar. Guarda o estado do lançamento ANTES, para o desfazer devolver exatamente
-- o que era. `origem`: manual | sugestao | criada (o lançamento nasceu da transação).
CREATE TABLE IF NOT EXISTS fin_conciliacoes (
  id                     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  origem                 VARCHAR(10)  NOT NULL DEFAULT 'manual',
  regra                  VARCHAR(20)  NULL,
  regra_versao           VARCHAR(12)  NULL,
  pontos                 INT          NULL,
  status_antes           VARCHAR(30)  NULL,              -- status do lançamento antes de conciliar
  pagamento_antes        DATE         NULL,
  conta_antes            INT UNSIGNED NULL,
  diferenca_centavos     BIGINT       NOT NULL DEFAULT 0,   -- transação − lançamento (juros, multa, desconto)
  justificativa          VARCHAR(255) NULL,
  status                 VARCHAR(10)  NOT NULL DEFAULT 'ativa',   -- ativa | desfeita
  usuario_id             INT UNSIGNED NULL,
  quando                 DATETIME     NOT NULL,
  desfeita_por           INT UNSIGNED NULL,
  desfeita_em            DATETIME     NULL,
  PRIMARY KEY (id),
  KEY fin_conc_status (status, quando)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Os pares (transação, lançamento) de uma conciliação. Hoje 1:1 — o par fica preso por duas UNIQUE
-- (`ativo_*`). `valor_alocado_centavos` já existe para o dia em que uma transação pagar duas parcelas.
CREATE TABLE IF NOT EXISTS fin_conciliacao_itens (
  id                     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conciliacao_id         BIGINT UNSIGNED NOT NULL,
  transacao_id           BIGINT UNSIGNED NOT NULL,
  lancamento_id          INT UNSIGNED    NOT NULL,
  valor_alocado_centavos BIGINT          NOT NULL,
  ativo_transacao        BIGINT UNSIGNED NULL,           -- = transacao_id enquanto ativo, NULL depois
  ativo_lancamento       INT UNSIGNED    NULL,           -- = lancamento_id enquanto ativo, NULL depois
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

-- O que o motor sugere. É derivado e refazível: rodar o motor de novo não cria linha repetida (UNIQUE),
-- e uma sugestão nunca altera lançamento nem transação.
CREATE TABLE IF NOT EXISTS fin_sugestoes (
  id                     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  transacao_id           BIGINT UNSIGNED NOT NULL,
  lancamento_id          INT UNSIGNED    NOT NULL,
  regra                  VARCHAR(20)  NOT NULL,
  regra_versao           VARCHAR(12)  NOT NULL,
  pontos                 INT          NOT NULL,
  forca                  VARCHAR(8)   NOT NULL,          -- forte | media | fraca
  motivos                TEXT         NULL,              -- JSON: o que bateu e o que não
  situacao               VARCHAR(10)  NOT NULL DEFAULT 'aberta',   -- aberta | aceita | rejeitada | obsoleta
  gerada_em              DATETIME     NOT NULL,
  atualizada_em          DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_sug_par (transacao_id, lancamento_id, regra_versao),
  KEY fin_sug_situacao (situacao, forca),
  KEY fin_sug_lanc (lancamento_id),
  CONSTRAINT fk_fin_sug_trans FOREIGN KEY (transacao_id) REFERENCES fin_transacoes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Os pares que a pessoa olhou e disse "não é este" (mesmo espírito de fin_duplicados_ok): o motor não os sugere de novo.
CREATE TABLE IF NOT EXISTS fin_sugestoes_rejeitadas (
  transacao_id           BIGINT UNSIGNED NOT NULL,
  lancamento_id          INT UNSIGNED    NOT NULL,
  usuario_id             INT UNSIGNED    NULL,
  quando                 DATETIME        NOT NULL,
  PRIMARY KEY (transacao_id, lancamento_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- O que cada confirmação ensina (09/11/2026): "este texto do extrato (a contraparte, sem PIX/TED/CNPJ) já foi ligado a
-- este fornecedor e a esta categoria N vezes". Deterministico e auditável: o Motor soma pontos por isso e a tela
-- preenche o "Lançar no financeiro" com o que mais se repetiu. Desfazer uma conciliação tira 1 da contagem.
CREATE TABLE IF NOT EXISTS fin_conc_aprendido (
  id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  chave                  VARCHAR(120) NOT NULL,          -- a contraparte do extrato, normalizada (Motor::contraparte)
  tipo                   VARCHAR(7)   NOT NULL,          -- Entrada | Saida
  fornecedor_id          INT UNSIGNED NOT NULL DEFAULT 0,
  categoria_id           INT UNSIGNED NOT NULL DEFAULT 0,
  vezes                  INT UNSIGNED NOT NULL DEFAULT 1,
  ultima_em              DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_aprend_chave (chave, tipo, fornecedor_id, categoria_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- O fechamento de um mês de uma conta: a foto dos números (e o hash dela, para saber se algo mudou depois).
-- `vigente` é 1 no fechamento valendo e NULL quando foi reaberto — só um por conta e mês.
CREATE TABLE IF NOT EXISTS fin_fechamentos (
  id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta_bancaria_id      INT UNSIGNED NOT NULL,
  competencia            CHAR(7)      NOT NULL,          -- AAAA-MM
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

-- "Vencido" não é status, é conta — a view calcula na hora (regra do módulo Financeiro).
-- SQL SECURITY INVOKER: roda com quem consulta. Sem isso a view guarda o DEFINER de
-- quem a criou — e, criada pelo MySQL Remoto (usuario@IP), quebra com "Access denied"
-- assim que esse IP é removido do cPanel (aconteceu em 21/09/2026).
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

-- ─────────────────────────────── scanner ───────────────────────────────
-- O Scanner continua sendo o .exe no Windows. Ele manda para cá o que
-- fez em cada lote (e o cadastro que alimentou), pela API com token.

CREATE TABLE IF NOT EXISTS scanner_lotes (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id    INT UNSIGNED NULL,
  quando        DATETIME     NOT NULL,
  maquina       VARCHAR(80)  NULL,
  arquivos      TEXT         NULL,       -- JSON com os PDFs de entrada
  pasta_saida   VARCHAR(255) NULL,
  paginas       INT NOT NULL DEFAULT 0,
  ok            INT NOT NULL DEFAULT 0,
  revisar       INT NOT NULL DEFAULT 0,
  erro          INT NOT NULL DEFAULT 0,
  competencia   VARCHAR(7)   NULL,
  motivos       TEXT         NULL,       -- principais motivos de revisão
  relatorio_csv VARCHAR(255) NULL,       -- relativo a dados/scanner
  PRIMARY KEY (id),
  KEY scanner_lotes_quando (quando)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS scanner_paginas (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  lote_id      INT UNSIGNED NOT NULL,
  pagina       INT          NOT NULL,
  categoria    VARCHAR(40)  NULL,
  colaborador  VARCHAR(140) NULL,       -- chave, quando casou com o cadastro
  nome_lido    VARCHAR(140) NULL,
  competencia  VARCHAR(7)   NULL,
  status       VARCHAR(12)  NULL,       -- OK | REVISAR | ERRO
  arquivo      VARCHAR(255) NULL,
  motivo       VARCHAR(255) NULL,
  cadastro     VARCHAR(255) NULL,       -- o que foi feito no cadastro
  PRIMARY KEY (id),
  KEY scanner_paginas_lote (lote_id),
  CONSTRAINT fk_scanner_paginas_lote FOREIGN KEY (lote_id) REFERENCES scanner_lotes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- O aprendizado do leitor de projeto.
--
-- Ler prancha de arquitetura é palpite educado: acerta muito e erra às vezes,
-- e o que corrige o palpite é a pessoa que conhece a obra. Estas três tabelas
-- guardam essa correção para ela não se perder — o mesmo projeto relido volta
-- com as medidas que valeram, e o nome de cômodo que o leitor não conhecia
-- passa a ser reconhecido no projeto seguinte, de qualquer cliente.
CREATE TABLE IF NOT EXISTS servicos_projetos (
  id         INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  impressao  CHAR(64)          NOT NULL,   -- SHA-256 do arquivo (o mesmo projeto renomeado continua o mesmo)
  arquivo    VARCHAR(255)      NOT NULL,
  paginas    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  lidos      SMALLINT UNSIGNED NOT NULL DEFAULT 0,   -- ambientes que o leitor achou
  lido_em    DATETIME          NOT NULL,
  usado_em   DATETIME          NULL,       -- quando virou proposta ou lista de material
  usuario_id INT UNSIGNED      NULL,
  PRIMARY KEY (id),
  UNIQUE KEY servicos_proj_impressao (impressao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Uma linha por ambiente: o que o leitor achou ao lado do que acabou valendo.
-- `corrigido` é o sinal que interessa — é dele que sai a régua de acerto do
-- leitor e a lista do que ele erra mais.
CREATE TABLE IF NOT EXISTS servicos_licoes (
  id          INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  projeto_id  INT UNSIGNED      NOT NULL,
  local       VARCHAR(120)      NOT NULL,
  pagina      SMALLINT UNSIGNED NULL,
  confianca   VARCHAR(6)        NULL,      -- alta | media | baixa, como o leitor entregou
  lado1_lido  DECIMAL(8,2)      NULL,      -- NULL = ambiente digitado à mão, o leitor não viu
  lado2_lido  DECIMAL(8,2)      NULL,
  area_lida   DECIMAL(10,2)     NULL,
  lado1       DECIMAL(8,2)      NOT NULL,  -- o que a pessoa usou de verdade
  lado2       DECIMAL(8,2)      NOT NULL,
  area        DECIMAL(10,2)     NULL,
  corrigido   TINYINT(1)        NOT NULL DEFAULT 0,
  quando      DATETIME          NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY servicos_licao_amb (projeto_id, local),
  KEY servicos_licao_local (local),
  CONSTRAINT fk_servicos_licoes_projeto FOREIGN KEY (projeto_id) REFERENCES servicos_projetos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- As palavras de nome de cômodo aprendidas em obra: BRINQUEDOTECA, PULMAO,
-- PRAINHA, SOLARIUM. Entram só de ambiente que virou proposta, e o leitor as
-- soma ao vocabulário de fábrica na leitura seguinte.
CREATE TABLE IF NOT EXISTS servicos_vocabulario (
  palavra   VARCHAR(60)  NOT NULL,
  vezes     INT UNSIGNED NOT NULL DEFAULT 1,
  criado_em DATETIME     NOT NULL,
  PRIMARY KEY (palavra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A base de estudo do preço de venda (`Servicos\Estudo`): uma linha por
-- proposta — gerada no sistema, antiga (PDF) ou fechada na calculadora .xlsx.
-- `calculado` é o que a tabela dava; `enviado` é o que saiu no papel. A
-- diferença entre os dois, e o preço implícito dos serviços sem preço, é o
-- material que os sócios e os agents estudam. Dinheiro em centavos.
CREATE TABLE IF NOT EXISTS servicos_estudo (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  chave       CHAR(64)      NOT NULL,   -- SHA-256 do caso: gerar a mesma proposta de novo não duplica
  origem      VARCHAR(12)   NOT NULL,   -- sistema | historico | planilha
  situacao    VARCHAR(10)   NOT NULL DEFAULT 'feito',  -- feito | fechado | teste (teste fica fora do estudo); 27/10/2026
  referencia  VARCHAR(160)  NOT NULL DEFAULT '',
  data        DATE          NOT NULL,
  projeto_id  INT UNSIGNED  NULL,       -- a prancha lida (servicos_projetos), quando houve
  linhas      MEDIUMTEXT    NOT NULL,   -- JSON: a memória de cálculo {codigo, trecho, medida, multiplicador}
  quantidades TEXT          NOT NULL,   -- JSON: {codigo: centésimos}
  parametros  TEXT          NOT NULL,   -- JSON: {frete, taxa, arredondar, rt}
  calculado   INT           NULL,       -- centavos: o que a conta dava (null = caso antigo, sem conta)
  enviado     INT           NOT NULL,   -- centavos: o valor da proposta
  escopo      TEXT          NOT NULL,
  observacao  VARCHAR(500)  NOT NULL DEFAULT '',
  tela        MEDIUMTEXT    NULL,       -- JSON: o retrato da tela, para reabrir e alterar (só proposta do sistema); 27/10/2026
  criado_em   DATETIME      NOT NULL,
  usuario_id  INT UNSIGNED  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY servicos_estudo_chave (chave),
  KEY servicos_estudo_data (data)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- O orçamento online do site (`Servicos\OrcamentoSite`, orcar.php): quem
-- soltou um projeto no site, o contato, o que o leitor achou (os ambientes do
-- modelo padrão) e a faixa de preço que viu. É um pedido para a equipe
-- comercial retornar e virar proposta formal (Serviços › Orçamentos do site).
-- O IP não é guardado: só o hash, para o limite de pedidos por visitante.
CREATE TABLE IF NOT EXISTS site_orcamentos (
  id            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  protocolo     VARCHAR(20)   NOT NULL,
  nome          VARCHAR(120)  NOT NULL,
  email         VARCHAR(160)  NOT NULL DEFAULT '',
  telefone      VARCHAR(20)   NOT NULL DEFAULT '',
  funcao        VARCHAR(20)   NOT NULL,   -- arquiteto | cliente
  arquivo       VARCHAR(160)  NOT NULL DEFAULT '',
  paginas       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  ambientes     MEDIUMTEXT    NOT NULL,   -- JSON: o modelo padrão lido no navegador do visitante
  area_m2       DECIMAL(9,2)  NOT NULL DEFAULT 0,
  valor_centavos INT          NULL,       -- a conta de venda do forro (o visitante NÃO vê este número)
  faixa_min     INT           NULL,       -- centavos: o que o visitante viu
  faixa_max     INT           NULL,
  situacao      VARCHAR(20)   NOT NULL DEFAULT 'novo',   -- novo | em contato | proposta | descartado
  observacao    VARCHAR(500)  NOT NULL DEFAULT '',
  ip_hash       CHAR(64)      NOT NULL,
  consentiu_em  DATETIME      NOT NULL,   -- o aceite de uso dos dados (LGPD)
  criado_em     DATETIME      NOT NULL,
  atualizado_em DATETIME      NULL,
  usuario_id    INT UNSIGNED  NULL,       -- quem atendeu por último
  PRIMARY KEY (id),
  UNIQUE KEY site_orcamentos_protocolo (protocolo),
  KEY site_orcamentos_situacao (situacao, criado_em),
  KEY site_orcamentos_ip (ip_hash, criado_em)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ─────────────────────── serviços: obras, medições e notas ───────────────────────
-- A obra é o contrato com o cliente — construtora (medição mensal assinada e
-- nota fiscal), avulso ou Club&Casa (em geral só a nota). Cliente sem obra
-- cadastrada também entra: o documento guarda o nome do cliente.
CREATE TABLE IF NOT EXISTS srv_obras (
  id                      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome                    VARCHAR(160) NOT NULL,
  cliente                 VARCHAR(160) NOT NULL,
  cliente_tipo            VARCHAR(20)  NOT NULL DEFAULT 'Construtora',   -- Construtora | Avulso | Club&Casa
  documento               VARCHAR(20)  NULL,          -- CNPJ ou CPF do cliente
  cidade                  VARCHAR(80)  NULL,
  situacao                VARCHAR(20)  NOT NULL DEFAULT 'Em andamento', -- Orçamento | Em andamento | Concluída | Cancelada
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

-- Medição (o que foi executado no período, assinada pela construtora) e nota
-- fiscal de serviço (o que foi faturado). A nota aponta a medição que fatura e o
-- lançamento de entrada que a recebeu no financeiro. "Faturada", "recebida" e
-- "vencida" não são gravadas: saem dessas ligações na hora, como o "vencido"
-- do financeiro.
CREATE TABLE IF NOT EXISTS srv_documentos (
  id                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo                VARCHAR(10)  NOT NULL,          -- medicao | nf
  obra_id             INT UNSIGNED NULL,
  cliente             VARCHAR(160) NOT NULL,
  cliente_tipo        VARCHAR(20)  NOT NULL DEFAULT 'Construtora',
  numero              VARCHAR(40)  NULL,
  emitente_cnpj       VARCHAR(14)  NULL,              -- nota: a empresa da casa que emitiu (cada uma numera as suas); entrou em 27/10/2026
  tomador_documento   VARCHAR(14)  NULL,              -- nota: CNPJ/CPF do cliente (só dígitos); entrou em 29/10/2026
  data_emissao        DATE         NOT NULL,          -- medição: data da medição; nota: emissão
  periodo_inicio      DATE         NULL,              -- período executado (medição)
  periodo_fim         DATE         NULL,
  valor_centavos      BIGINT       NOT NULL DEFAULT 0,   -- bruto
  retencoes_centavos  BIGINT       NOT NULL DEFAULT 0,   -- INSS, ISS, IR retidos na nota
  vencimento          DATE         NULL,              -- nota: quando o dinheiro deve cair
  situacao            VARCHAR(24)  NOT NULL,          -- medição: Aguardando assinatura | Assinada | Cancelada; nota: Emitida | Cancelada
  conferencia         VARCHAR(12)  NOT NULL DEFAULT 'conferida',   -- nota: a_conferir (ainda não se viu se foi paga) | conferida; entrou em 29/10/2026
  conferido_em        DATETIME     NULL,
  conferido_por       INT UNSIGNED NULL,
  pago_em             DATE         NULL,              -- nota paga FORA do sistema (sem lançamento no financeiro): o dia em que caiu
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

-- Os arquivos de cada documento (o PDF assinado, o PDF e o XML da nota).
-- Moram em dados/anexos, como os do financeiro.
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

-- O histórico de cada nota (29/10/2026): quando foi lançada, os lançamentos de valor parecido que existiam na hora,
-- cada conferência, ligação ou soltura do recebimento. Só cresce; nada aqui se apaga.
CREATE TABLE IF NOT EXISTS srv_doc_historico (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  documento_id  INT UNSIGNED NOT NULL,
  quando        DATETIME     NOT NULL,
  usuario_id    INT UNSIGNED NULL,
  evento        VARCHAR(24)  NOT NULL,          -- lancada | semelhantes | conferida | paga_fora | reaberta | vinculada | solta | recebimento_gerado
  texto         VARCHAR(255) NOT NULL,
  dados         MEDIUMTEXT   NULL,              -- JSON: os lançamentos parecidos daquela hora
  PRIMARY KEY (id),
  KEY srv_doc_hist (documento_id, quando)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Caixa de entrada de e-mails (14/10/2026) ────────────────────────────────────────────────
-- Boletos e notas que chegaram por e-mail, antes de virarem lançamento. O coletor (Python,
-- scripts/caixa_coletar.py) lê as caixas por IMAP SÓ PARA LER; o PHP (Caixa::absorver) guarda aqui.
-- Nada daqui cria ou altera lançamento: quem lança é a pessoa, pela revisão do boleto.
-- A chave de cada e-mail é (conta, pasta, uidvalidity, uid): recolher o mesmo e-mail não duplica.
CREATE TABLE IF NOT EXISTS fin_caixa_emails (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta           VARCHAR(60)  NOT NULL,            -- o nome da conta em contas.json
  pasta           VARCHAR(120) NOT NULL,
  uidvalidity     BIGINT UNSIGNED NOT NULL,
  uid             BIGINT UNSIGNED NOT NULL,
  message_id      VARCHAR(255) NULL,
  remetente_nome  VARCHAR(200) NULL,
  remetente_email VARCHAR(190) NULL,
  assunto         VARCHAR(500) NULL,
  recebido_em     DATETIME     NULL,
  trecho          TEXT         NULL,                -- o começo do texto do e-mail
  links           TEXT         NULL,                -- JSON: links de portal que parecem boleto/nota
  linhas_corpo    TEXT         NULL,                -- JSON: números de 44-48 dígitos achados no texto
  avisos          TEXT         NULL,                -- JSON: o que o coletor não conseguiu abrir
  tem_anexo       TINYINT(1)   NOT NULL DEFAULT 0,
  estado          VARCHAR(12)  NOT NULL DEFAULT 'novo',   -- só vale para e-mail SEM anexo: novo | visto
  decidido_em     DATETIME     NULL,
  decidido_por    INT UNSIGNED NULL,
  coletado_em     DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY fin_cx_email_uid (conta, pasta, uidvalidity, uid),
  KEY fin_cx_email_data (recebido_em),
  KEY fin_cx_email_msg (message_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Cada anexo que pode ser boleto ou nota. `estado`: novo | lancado | ignorado | repetido.
-- `lancamento_id` NÃO tem chave estrangeira de propósito: excluir um lançamento não pode ser
-- barrado pela Caixa — o anexo apenas volta para "novo" (a lista confere se o lançamento existe).
CREATE TABLE IF NOT EXISTS fin_caixa_anexos (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  email_id      INT UNSIGNED NOT NULL,
  nome          VARCHAR(200) NOT NULL,
  extensao      VARCHAR(8)   NOT NULL,
  tamanho       INT UNSIGNED NOT NULL,
  sha256        CHAR(64)     NOT NULL,
  caminho       VARCHAR(255) NOT NULL,              -- relativo a dados/caixa/arquivos
  tipo          VARCHAR(12)  NOT NULL DEFAULT 'a_ler',   -- a_ler | boleto | nota | nfe_xml | nfse_xml | xml | outro
  leitura       TEXT         NULL,                  -- JSON: o resumo (valor, vencimento, quem)
  lido_em       DATETIME     NULL,
  estado        VARCHAR(12)  NOT NULL DEFAULT 'novo',
  lancamento_id INT UNSIGNED NULL,
  repetido_de   INT UNSIGNED NULL,                  -- o mesmo arquivo já visto em outro e-mail
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

-- Cada coleta, por conta: é o que prova que o coletor rodou (e quando parou de rodar).
CREATE TABLE IF NOT EXISTS fin_caixa_coletas (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conta        VARCHAR(60)  NOT NULL,
  iniciou_em   DATETIME     NOT NULL,
  terminou_em  DATETIME     NULL,
  ok           TINYINT(1)   NOT NULL DEFAULT 1,
  erro         VARCHAR(500) NULL,
  vistos       INT UNSIGNED NOT NULL DEFAULT 0,     -- e-mails olhados
  guardados    INT UNSIGNED NOT NULL DEFAULT 0,     -- os que pareciam boleto/nota
  ignorados    INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY fin_cx_coleta_conta (conta, terminou_em)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- O "conferi hoje" das origens que não chegam por e-mail (site, WhatsApp, fatura do dia 17): um visto
-- por origem e por dia. O nome da origem vem de dados/caixa/fontes.json.
CREATE TABLE IF NOT EXISTS fin_caixa_checagens (
  fonte       VARCHAR(80)  NOT NULL,
  dia         DATE         NOT NULL,
  usuario_id  INT UNSIGNED NULL,
  criado_em   DATETIME     NOT NULL,
  PRIMARY KEY (fonte, dia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- "Não é este lançamento": a pessoa disse que o anexo da Caixa NÃO corresponde àquele lançamento — a conciliação
-- não propõe o par de novo. (Guardar o "não" é o que deixa a conciliação automática ser precisa sem ser teimosa.)
CREATE TABLE IF NOT EXISTS fin_caixa_nao_casa (
  anexo_id       INT UNSIGNED NOT NULL,
  lancamento_id  INT UNSIGNED NOT NULL,
  usuario_id     INT UNSIGNED NULL,
  criado_em      DATETIME     NOT NULL,
  PRIMARY KEY (anexo_id, lancamento_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Preços e composições (28/10/2026) ───────────────────────────────────────────────────────
-- O banco de preços de Serviços: o que antes morava em constante no PHP (Precificacao::CATALOGO,
-- Levantamento::MATERIAIS) e em planilha de composição (a da WTC de 08/2026). Quatro peças:
--   * materiais, com o preço de CADA fornecedor e o histórico (uma linha por mudança);
--   * serviços, cada um com um código e a especificação (montante, placas de cada face, isolamento);
--   * a composição: quanto de cada material vai em 1 unidade do serviço (m², m, und);
--   * as tabelas de VENDA (pequeno / médio / grande porte, ou a de uma construtora), com histórico.
-- Toda gravação também entra na fila do espelho no Supabase (srv_espelho) — ver Servicos\Espelho.
CREATE TABLE IF NOT EXISTS srv_materiais (
  id                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo             VARCHAR(30)  NOT NULL,            -- MONT-90, PLACA-ST, LA-VIDRO-50…
  nome               VARCHAR(120) NOT NULL,
  categoria          VARCHAR(20)  NOT NULL DEFAULT 'outro',  -- perfil, placa, isolamento, fixacao, acabamento, outro
  unidade            VARCHAR(12)  NOT NULL,            -- a unidade do CONSUMO: m, m², un, kg, vb
  unidade_compra     VARCHAR(30)  NOT NULL,            -- barra 3 m, caixa 1000, balde 25 kg…
  rendimento         DOUBLE       NOT NULL DEFAULT 1,  -- quantas unidades de consumo vêm numa de compra
  fornecedor_padrao  VARCHAR(60)  NULL,
  chave_levantamento VARCHAR(20)  NULL,                -- liga ao Levantamento::MATERIAIS (lista do forro)
  ativo              TINYINT(1)   NOT NULL DEFAULT 1,
  observacao         VARCHAR(255) NULL,
  atualizado_em      DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_mat_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- O preço de um material num fornecedor, a partir de uma data. Mudou o preço? Linha nova
-- (no mesmo dia, substitui). O preço que vale é o da data mais recente até hoje.
CREATE TABLE IF NOT EXISTS srv_material_precos (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  material_id    INT UNSIGNED NOT NULL,
  fornecedor     VARCHAR(60)  NOT NULL,
  preco          INT          NOT NULL,                -- centavos por UNIDADE DE COMPRA
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
  codigo         VARCHAR(20)  NOT NULL,                -- FT-01, PA-04, SH-01… (o da conta de venda)
  familia        VARCHAR(12)  NOT NULL,                -- FORRO, PAREDE, SHAFT, MURETA, SANCA, VIGA, REFORCO, OUTRO
  nome           VARCHAR(160) NOT NULL,
  unidade        VARCHAR(6)   NOT NULL,                -- m², m, und, vb
  sigla          VARCHAR(6)   NOT NULL DEFAULT '',     -- como sai na proposta: M², ML, UN
  texto          VARCHAR(255) NOT NULL,                -- o texto da proposta
  especificacao  TEXT         NULL,                    -- JSON: montante, espacamento, estrutura, face_a, face_b, isolamento
  tecnico        VARCHAR(120) NULL,                    -- o código técnico tirado da especificação (140/90/400 MS 2ST+2ST LV)
  mao_de_obra    INT          NULL,                    -- centavos por unidade do serviço (a M.O. da composição)
  ordem          INT          NOT NULL DEFAULT 0,
  ativo          TINYINT(1)   NOT NULL DEFAULT 1,
  atualizado_em  DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_serv_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Quanto de cada material vai em UMA unidade do serviço (por m² de parede, por m de sanca).
CREATE TABLE IF NOT EXISTS srv_composicoes (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  servico_id   INT UNSIGNED NOT NULL,
  material_id  INT UNSIGNED NOT NULL,
  consumo      DOUBLE       NOT NULL,                  -- na unidade de consumo do material
  ordem        INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY srv_comp_chave (servico_id, material_id),
  KEY srv_comp_mat (material_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- As tabelas de VENDA. As três de porte nascem no instalar.php (PEQUENO = a tabela da empresa de
-- sempre, que é a da calculadora .xlsx); a de uma construtora (WTC 08/2026) entra pelo importador.
CREATE TABLE IF NOT EXISTS srv_tabelas (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo         VARCHAR(20)  NOT NULL,
  nome           VARCHAR(80)  NOT NULL,
  porte          VARCHAR(10)  NOT NULL DEFAULT 'pequeno',   -- pequeno, medio, grande
  descricao      VARCHAR(255) NULL,
  ordem          INT          NOT NULL DEFAULT 0,
  ativo          TINYINT(1)   NOT NULL DEFAULT 1,
  atualizado_em  DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_tab_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- O preço de venda de um serviço numa tabela, a partir de uma data. `preco` NULL = sem preço
-- (de propósito: trava a conta de venda até alguém definir).
CREATE TABLE IF NOT EXISTS srv_tabela_precos (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tabela_id      INT UNSIGNED NOT NULL,
  servico_id     INT UNSIGNED NOT NULL,
  preco          INT          NULL,                    -- centavos por unidade do serviço
  vigente_desde  DATE         NOT NULL,
  observacao     VARCHAR(255) NULL,
  usuario_id     INT UNSIGNED NULL,
  criado_em      DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_tabpreco_chave (tabela_id, servico_id, vigente_desde),
  KEY srv_tabpreco_serv (servico_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A fila do espelho no Supabase: o que mudou aqui e ainda não chegou lá (tabela + chave
-- natural). Sai da fila quando o Supabase confirma; o Supabase fora do ar não trava gravação.
CREATE TABLE IF NOT EXISTS srv_espelho (
  tabela      VARCHAR(30)  NOT NULL,
  chave       VARCHAR(120) NOT NULL,
  criado_em   DATETIME     NOT NULL,
  tentativas  INT UNSIGNED NOT NULL DEFAULT 0,
  erro        VARCHAR(255) NULL,
  PRIMARY KEY (tabela, chave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ───────────────── medição da produção dos colaboradores (05/11/2026) ───────────────
-- Serviços › Medição da produção: o que cada colaborador fez no mês (o texto que ele manda,
-- ou a planilha LEVANTAMENTO MEDIÇÃO), lido em itens, multiplicado pela tabela de mão de
-- obra e levado para Financeiro › Produção. Tudo em centavos inteiros; quantidade em
-- milésimos (1,234 m² = 1234) — nunca ponto flutuante na conta.

-- A tabela de preços da medição: uma FAIXA por serviço (mínimo–máximo), como na planilha dos sócios.
CREATE TABLE IF NOT EXISTS srv_med_servicos (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo        VARCHAR(20)  NOT NULL,
  nome          VARCHAR(120) NOT NULL,
  unidade       VARCHAR(4)   NOT NULL,                 -- m2 | ml | un
  regra         VARCHAR(255) NULL,                     -- como a quantidade é tirada das medidas (texto para a tela)
  mo_min        INT          NULL,                     -- mão de obra, centavos por unidade
  mo_max        INT          NULL,
  mat_min       INT          NULL,                     -- material + mão de obra
  mat_max       INT          NULL,
  mo_fixo       INT          NULL,                     -- valor combinado: quando existe, vale no lugar da faixa
  servico_venda    VARCHAR(20) NULL,                     -- srv_servicos.codigo: o serviço de Preços e composições que este representa
  mo_da_composicao TINYINT(1)  NOT NULL DEFAULT 0,       -- 1 = sem faixa própria, vale a mão de obra da composição desse serviço
  ativo         TINYINT(1)   NOT NULL DEFAULT 1,
  ordem         SMALLINT     NOT NULL DEFAULT 0,
  atualizado_em DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY srv_medserv_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Uma medição = um colaborador num mês. `tabela` guarda os preços do dia em que foi salva:
-- mudar a tabela depois não refaz a medição de outubro.
CREATE TABLE IF NOT EXISTS srv_med_medicoes (
  id                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  competencia       CHAR(7)      NOT NULL,             -- AAAA-MM (o mês da folha de Produção)
  nome              VARCHAR(140) NOT NULL,             -- como está na folha (sufixos como JUNIOR)
  faixa             CHAR(3)      NOT NULL DEFAULT 'med',   -- min | med | max
  tabela_venda      VARCHAR(20)  NOT NULL DEFAULT 'PEQUENO',   -- a tabela de venda usada no cruzamento (valor produzido)
  texto             MEDIUMTEXT   NULL,                 -- o texto como chegou
  origem            VARCHAR(10)  NOT NULL DEFAULT 'texto',   -- texto | planilha
  arquivo           VARCHAR(190) NULL,
  observacao        VARCHAR(255) NULL,
  tabela            MEDIUMTEXT   NULL,                 -- JSON: preços de cada serviço quando foi salva
  total_mo          BIGINT       NOT NULL DEFAULT 0,
  total_mat         BIGINT       NOT NULL DEFAULT 0,
  levado_em         DATETIME     NULL,                 -- quando foi para a Produção
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
  local_txt   VARCHAR(140) NULL,                       -- pavimento · apartamento · seção
  descricao   VARCHAR(400) NOT NULL,
  original    VARCHAR(500) NULL,                       -- a linha como chegou
  servico     VARCHAR(20)  NULL,                       -- srv_med_servicos.codigo; NULL = a conferir
  contagem    INT          NOT NULL DEFAULT 1,
  medidas     VARCHAR(255) NULL,
  qtd_mil     BIGINT       NULL,                       -- quantidade × 1000 na unidade do serviço
  qtd_manual  TINYINT(1)   NOT NULL DEFAULT 0,         -- 1 = a quantidade foi digitada, não calculada
  conferido   TINYINT(1)   NOT NULL DEFAULT 0,         -- 1 = alguém conferiu e aceitou (inclusive medida suspeita)
  preco_mo    INT          NULL,                       -- preço combinado só para esta linha (centavos)
  aviso       VARCHAR(400) NULL,
  confianca   VARCHAR(8)   NOT NULL DEFAULT 'alta',    -- alta | media | baixa
  PRIMARY KEY (id),
  KEY srv_meditem_med (medicao_id, ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
