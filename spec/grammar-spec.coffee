describe "SQL grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-sql")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.sql")

  it "parses the grammar", ->
    expect(grammar).toBeDefined()
    expect(grammar.scopeName).toBe "source.sql"

  it "uses not as a keyword", ->
    {tokens} = grammar.tokenizeLine('NOT')
    expect(tokens[0]).toEqual value: 'NOT', scopes: ['source.sql', 'keyword.other.not.sql']

  it 'tokenizes integers', ->
    {tokens} = grammar.tokenizeLine('12345')
    expect(tokens[0]).toEqual value: '12345', scopes: ['source.sql', 'constant.numeric.sql']

  it 'tokenizes integers ending words', ->
    {tokens} = grammar.tokenizeLine('field1')
    expect(tokens[0]).toEqual value: 'field1', scopes: ['source.sql']

    {tokens} = grammar.tokenizeLine('2field')
    expect(tokens[0]).toEqual value: '2field', scopes: ['source.sql']

    {tokens} = grammar.tokenizeLine('link_from_1_to_2')
    expect(tokens[0]).toEqual value: 'link_from_1_to_2', scopes: ['source.sql']

    {tokens} = grammar.tokenizeLine('create table t1')
    expect(tokens[4]).toEqual value: 't1', scopes: ['source.sql', 'meta.create.sql', 'entity.name.function.sql']

  it 'tokenizes numbers with decimals in them', ->
    {tokens} = grammar.tokenizeLine('123.45')
    expect(tokens[0]).toEqual value: '123.45', scopes: ['source.sql', 'constant.numeric.sql']

    {tokens} = grammar.tokenizeLine('123.')
    expect(tokens[0]).toEqual value: '123.', scopes: ['source.sql', 'constant.numeric.sql']

    {tokens} = grammar.tokenizeLine('.123')
    expect(tokens[0]).toEqual value: '.123', scopes: ['source.sql', 'constant.numeric.sql']

  it 'tokenizes add', ->
    {tokens} = grammar.tokenizeLine('ADD CONSTRAINT')
    expect(tokens[0]).toEqual value: 'ADD', scopes: ['source.sql', 'meta.add.sql', 'keyword.other.create.sql']

  it 'tokenizes create', ->
    {tokens} = grammar.tokenizeLine('CREATE TABLE')
    expect(tokens[0]).toEqual value: 'CREATE', scopes: ['source.sql', 'meta.create.sql', 'keyword.other.create.sql']

  it 'does not tokenize create for non-SQL keywords', ->
    {tokens} = grammar.tokenizeLine('CREATE TABLEOHNO')
    expect(tokens[0]).toEqual value: 'CREATE TABLEOHNO', scopes: ['source.sql']

  it 'tokenizes create if not exists', ->
    {tokens} = grammar.tokenizeLine('CREATE TABLE IF NOT EXISTS t1')
    expect(tokens[0]).toEqual value: 'CREATE', scopes: ['source.sql', 'meta.create.sql', 'keyword.other.create.sql']
    expect(tokens[2]).toEqual value: 'TABLE', scopes: ['source.sql', 'meta.create.sql', 'keyword.other.sql' ]
    expect(tokens[4]).toEqual value: 'IF NOT EXISTS', scopes: ['source.sql', 'meta.create.sql', 'keyword.other.DML.sql' ]
    expect(tokens[6]).toEqual value: 't1', scopes: ['source.sql', 'meta.create.sql', 'entity.name.function.sql' ]

  it 'tokenizes drop', ->
    {tokens} = grammar.tokenizeLine('DROP CONSTRAINT')
    expect(tokens[0]).toEqual value: 'DROP', scopes: ['source.sql', 'meta.drop.sql', 'keyword.other.drop.sql']

  it 'does not tokenize drop for non-SQL keywords', ->
    {tokens} = grammar.tokenizeLine('DROP CONSTRAINTOHNO')
    expect(tokens[0]).toEqual value: 'DROP CONSTRAINTOHNO', scopes: ['source.sql']

  it 'tokenizes drop if exists', ->
    {tokens} = grammar.tokenizeLine('DROP TABLE IF EXISTS t1')
    expect(tokens[0]).toEqual value: 'DROP', scopes: ['source.sql', 'meta.drop.sql', 'keyword.other.drop.sql']
    expect(tokens[2]).toEqual value: 'TABLE', scopes: ['source.sql', 'meta.drop.sql', 'keyword.other.sql' ]
    expect(tokens[4]).toEqual value: 'IF EXISTS', scopes: ['source.sql', 'meta.drop.sql', 'keyword.other.DML.sql' ]
    expect(tokens[6]).toEqual value: 't1', scopes: ['source.sql', 'meta.drop.sql', 'entity.name.function.sql' ]

  it 'tokenizes with', ->
    {tokens} = grammar.tokenizeLine('WITH field')
    expect(tokens[0]).toEqual value: 'WITH', scopes: ['source.sql', 'keyword.other.DML.sql']

  it 'tokenizes conditional expressions', ->
    {tokens} = grammar.tokenizeLine('COALESCE(a,b)')
    expect(tokens[0]).toEqual value: 'COALESCE', scopes: ['source.sql', 'keyword.other.conditional.sql']

    {tokens} = grammar.tokenizeLine('NVL(a,b)')
    expect(tokens[0]).toEqual value: 'NVL', scopes: ['source.sql', 'keyword.other.conditional.sql']

    {tokens} = grammar.tokenizeLine('NULLIF(a,b)')
    expect(tokens[0]).toEqual value: 'NULLIF', scopes: ['source.sql', 'keyword.other.conditional.sql']

  it 'tokenizes unique', ->
    {tokens} = grammar.tokenizeLine('UNIQUE(id)')
    expect(tokens[0]).toEqual value: 'UNIQUE', scopes: ['source.sql', 'storage.modifier.sql']

  it 'tokenizes scalar functions', ->
    {tokens} = grammar.tokenizeLine('SELECT CURRENT_DATE')
    expect(tokens[2]).toEqual value: 'CURRENT_DATE', scopes: ['source.sql', 'support.function.scalar.sql']

  it 'tokenizes math functions', ->
    {tokens} = grammar.tokenizeLine('SELECT ABS(-4)')
    expect(tokens[2]).toEqual value: 'ABS', scopes: ['source.sql', 'support.function.math.sql']

  it 'tokenizes window functions', ->
    {tokens} = grammar.tokenizeLine('SELECT ROW_NUMBER()')
    expect(tokens[2]).toEqual value: 'ROW_NUMBER', scopes: ['source.sql', 'support.function.window.sql']

  it "quotes strings", ->
    {tokens} = grammar.tokenizeLine('"Test"')
    expect(tokens[0]).toEqual value: '"', scopes: ['source.sql', 'string.quoted.double.sql', 'punctuation.definition.string.begin.sql']
    expect(tokens[1]).toEqual value: 'Test', scopes: ['source.sql', 'string.quoted.double.sql']
    expect(tokens[2]).toEqual value: '"', scopes: ['source.sql', 'string.quoted.double.sql', 'punctuation.definition.string.end.sql']

  it 'tokenizes column types', ->
    lines = grammar.tokenizeLines('''
    bigserial
    boolean
    box
    bytea
    cidr
    circle
    date
    datetime
    datetime2
    double precision
    enum
    inet
    integer
    interval
    line
    lseg
    macaddr
    money
    oid
    path
    point
    polygon
    real
    serial
    sysdate
    text
    uniqueidentifier

    bigint
    bigint()
    bigint(1)
    bit
    bit()
    bit(1)
    bit varying
    bit varying()
    bit varying(1)
    char
    char()
    char(1)
    character
    character()
    character(1)
    character varying
    character varying()
    character varying(1)
    float
    float()
    float(1)
    int
    int()
    int(1)
    number
    number()
    number(1)
    smallint
    smallint()
    smallint(1)
    timestamptz
    timestamptz()
    timestamptz(1)
    timetz
    timetz()
    timetz(1)
    tinyint
    tinyint()
    tinyint(1)
    varchar
    varchar()
    varchar(1)
    nvarchar
    nvarchar()
    nvarchar(1)
    nvarchar2
    nvarchar2()
    nvarchar2(1)

    numeric
    numeric()
    numeric(1)
    numeric(1,1)
    decimal
    decimal()
    decimal(1)
    decimal(1,1)

    time
    time with time zone
    time without time zone
    time()
    time() with time zone
    time() without time zone
    time(1)
    time(1) with time zone
    time(1) without time zone
    timestamp
    timestamp with time zone
    timestamp without time zone
    timestamp()
    timestamp() with time zone
    timestamp() without time zone
    timestamp(1)
    timestamp(1) with time zone
    timestamp(1) without time zone
    ''')
    expect(lines[0][0]).toEqual value: 'bigserial', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[1][0]).toEqual value: 'boolean', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[2][0]).toEqual value: 'box', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[3][0]).toEqual value: 'bytea', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[4][0]).toEqual value: 'cidr', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[5][0]).toEqual value: 'circle', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[6][0]).toEqual value: 'date', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[7][0]).toEqual value: 'datetime', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[8][0]).toEqual value: 'datetime2', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[9][0]).toEqual value: 'double precision', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[10][0]).toEqual value: 'enum', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[11][0]).toEqual value: 'inet', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[12][0]).toEqual value: 'integer', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[13][0]).toEqual value: 'interval', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[14][0]).toEqual value: 'line', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[15][0]).toEqual value: 'lseg', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[16][0]).toEqual value: 'macaddr', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[17][0]).toEqual value: 'money', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[18][0]).toEqual value: 'oid', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[19][0]).toEqual value: 'path', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[20][0]).toEqual value: 'point', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[21][0]).toEqual value: 'polygon', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[22][0]).toEqual value: 'real', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[23][0]).toEqual value: 'serial', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[24][0]).toEqual value: 'sysdate', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[25][0]).toEqual value: 'text', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[26][0]).toEqual value: 'uniqueidentifier', scopes: ['source.sql', 'storage.type.sql']

    expect(lines[28][0]).toEqual value: 'bigint', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[29][0]).toEqual value: 'bigint', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[29][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[29][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[30][0]).toEqual value: 'bigint', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[30][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[30][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[30][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[31][0]).toEqual value: 'bit', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[32][0]).toEqual value: 'bit', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[32][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[32][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[33][0]).toEqual value: 'bit', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[33][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[33][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[33][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[34][0]).toEqual value: 'bit varying', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[35][0]).toEqual value: 'bit varying', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[35][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[35][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[36][0]).toEqual value: 'bit varying', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[36][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[36][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[36][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[37][0]).toEqual value: 'char', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[38][0]).toEqual value: 'char', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[38][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[38][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[39][0]).toEqual value: 'char', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[39][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[39][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[39][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[40][0]).toEqual value: 'character', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[41][0]).toEqual value: 'character', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[41][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[41][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[42][0]).toEqual value: 'character', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[42][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[42][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[42][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[43][0]).toEqual value: 'character varying', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[44][0]).toEqual value: 'character varying', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[44][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[44][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[45][0]).toEqual value: 'character varying', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[45][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[45][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[45][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[46][0]).toEqual value: 'float', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[47][0]).toEqual value: 'float', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[47][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[47][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[48][0]).toEqual value: 'float', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[48][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[48][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[48][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[49][0]).toEqual value: 'int', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[50][0]).toEqual value: 'int', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[50][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[50][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[51][0]).toEqual value: 'int', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[51][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[51][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[51][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[52][0]).toEqual value: 'number', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[53][0]).toEqual value: 'number', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[53][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[53][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[54][0]).toEqual value: 'number', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[54][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[54][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[54][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[55][0]).toEqual value: 'smallint', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[56][0]).toEqual value: 'smallint', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[56][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[56][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[57][0]).toEqual value: 'smallint', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[57][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[57][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[57][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[58][0]).toEqual value: 'timestamptz', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[59][0]).toEqual value: 'timestamptz', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[59][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[59][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[60][0]).toEqual value: 'timestamptz', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[60][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[60][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[60][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[61][0]).toEqual value: 'timetz', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[62][0]).toEqual value: 'timetz', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[62][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[62][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[63][0]).toEqual value: 'timetz', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[63][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[63][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[63][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[64][0]).toEqual value: 'tinyint', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[65][0]).toEqual value: 'tinyint', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[65][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[65][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[66][0]).toEqual value: 'tinyint', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[66][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[66][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[66][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[67][0]).toEqual value: 'varchar', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[68][0]).toEqual value: 'varchar', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[68][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[68][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[69][0]).toEqual value: 'varchar', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[69][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[69][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[69][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[70][0]).toEqual value: 'nvarchar', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[71][0]).toEqual value: 'nvarchar', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[71][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[71][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[72][0]).toEqual value: 'nvarchar', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[72][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[72][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[72][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[73][0]).toEqual value: 'nvarchar2', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[74][0]).toEqual value: 'nvarchar2', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[74][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[74][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[75][0]).toEqual value: 'nvarchar2', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[75][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[75][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[75][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']

    expect(lines[77][0]).toEqual value: 'numeric', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[78][0]).toEqual value: 'numeric', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[78][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[78][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[79][0]).toEqual value: 'numeric', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[79][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[79][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[79][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[80][0]).toEqual value: 'numeric', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[80][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[80][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[80][3]).toEqual value: ',', scopes: ['source.sql', 'punctuation.separator.parameters.comma.sql']
    expect(lines[80][4]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[80][5]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[81][0]).toEqual value: 'decimal', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[82][0]).toEqual value: 'decimal', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[82][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[82][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[83][0]).toEqual value: 'decimal', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[83][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[83][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[83][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[84][0]).toEqual value: 'decimal', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[84][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[84][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[84][3]).toEqual value: ',', scopes: ['source.sql', 'punctuation.separator.parameters.comma.sql']
    expect(lines[84][4]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[84][5]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']

    expect(lines[86][0]).toEqual value: 'time', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[87][0]).toEqual value: 'time', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[87][2]).toEqual value: 'with time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[88][0]).toEqual value: 'time', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[88][2]).toEqual value: 'without time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[89][0]).toEqual value: 'time', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[89][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[89][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[90][0]).toEqual value: 'time', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[90][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[90][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[90][4]).toEqual value: 'with time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[91][0]).toEqual value: 'time', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[91][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[91][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[91][4]).toEqual value: 'without time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[92][0]).toEqual value: 'time', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[92][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[92][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[92][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[93][0]).toEqual value: 'time', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[93][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[93][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[93][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[93][5]).toEqual value: 'with time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[94][0]).toEqual value: 'time', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[94][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[94][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[94][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[94][5]).toEqual value: 'without time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[95][0]).toEqual value: 'timestamp', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[96][0]).toEqual value: 'timestamp', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[96][2]).toEqual value: 'with time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[97][0]).toEqual value: 'timestamp', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[97][2]).toEqual value: 'without time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[98][0]).toEqual value: 'timestamp', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[98][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[98][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[99][0]).toEqual value: 'timestamp', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[99][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[99][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[99][4]).toEqual value: 'with time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[100][0]).toEqual value: 'timestamp', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[100][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[100][2]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[100][4]).toEqual value: 'without time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[101][0]).toEqual value: 'timestamp', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[101][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[101][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[101][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[102][0]).toEqual value: 'timestamp', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[102][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[102][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[102][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[102][5]).toEqual value: 'with time zone', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[103][0]).toEqual value: 'timestamp', scopes: ['source.sql', 'storage.type.sql']
    expect(lines[103][1]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.begin.sql']
    expect(lines[103][2]).toEqual value: '1', scopes: ['source.sql', 'constant.numeric.sql']
    expect(lines[103][3]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.parameters.bracket.round.end.sql']
    expect(lines[103][5]).toEqual value: 'without time zone', scopes: ['source.sql', 'storage.type.sql']

  it 'tokenizes comments', ->
    {tokens} = grammar.tokenizeLine('-- comment')
    expect(tokens[0]).toEqual value: '--', scopes: ['source.sql', 'comment.line.double-dash.sql', 'punctuation.definition.comment.sql']
    expect(tokens[1]).toEqual value: ' comment', scopes: ['source.sql', 'comment.line.double-dash.sql']

    {tokens} = grammar.tokenizeLine('AND -- WITH')

    expect(tokens[0]).toEqual value: 'AND', scopes: ['source.sql', 'keyword.other.DML.sql']
    expect(tokens[2]).toEqual value: '--', scopes: ['source.sql', 'comment.line.double-dash.sql', 'punctuation.definition.comment.sql']
    expect(tokens[3]).toEqual value: ' WITH', scopes: ['source.sql', 'comment.line.double-dash.sql']

    {tokens} = grammar.tokenizeLine('/* comment */')
    expect(tokens[0]).toEqual value: '/*', scopes: ['source.sql', 'comment.block.sql', 'punctuation.definition.comment.sql']
    expect(tokens[1]).toEqual value: ' comment ', scopes: ['source.sql', 'comment.block.sql']
    expect(tokens[2]).toEqual value: '*/', scopes: ['source.sql', 'comment.block.sql', 'punctuation.definition.comment.sql']

    {tokens} = grammar.tokenizeLine('SELECT /* WITH */ AND')
    expect(tokens[0]).toEqual value: 'SELECT', scopes: ['source.sql', 'keyword.other.DML.sql']
    expect(tokens[2]).toEqual value: '/*', scopes: ['source.sql', 'comment.block.sql', 'punctuation.definition.comment.sql']
    expect(tokens[3]).toEqual value: ' WITH ', scopes: ['source.sql', 'comment.block.sql']
    expect(tokens[4]).toEqual value: '*/', scopes: ['source.sql', 'comment.block.sql', 'punctuation.definition.comment.sql']
    expect(tokens[6]).toEqual value: 'AND', scopes: ['source.sql', 'keyword.other.DML.sql']

  it 'tokenizes ()', ->
    {tokens} = grammar.tokenizeLine('WHERE salary > (SELECT avg(salary) FROM employees)')
    expect(tokens[0]).toEqual value: 'WHERE', scopes: ['source.sql', 'keyword.other.DML.sql']
    expect(tokens[1]).toEqual value: ' salary ', scopes: ['source.sql']
    expect(tokens[2]).toEqual value: '>', scopes: ['source.sql', 'keyword.operator.comparison.sql']
    expect(tokens[4]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.section.bracket.round.begin.sql']
    expect(tokens[5]).toEqual value: 'SELECT', scopes: ['source.sql', 'keyword.other.DML.sql']
    expect(tokens[7]).toEqual value: 'avg', scopes: ['source.sql', 'support.function.aggregate.sql']
    expect(tokens[8]).toEqual value: '(', scopes: ['source.sql', 'punctuation.definition.section.bracket.round.begin.sql']
    expect(tokens[9]).toEqual value: 'salary', scopes: ['source.sql']
    expect(tokens[10]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.section.bracket.round.end.sql']
    expect(tokens[12]).toEqual value: 'FROM', scopes: ['source.sql', 'keyword.other.DML.sql']
    expect(tokens[13]).toEqual value: ' employees', scopes: ['source.sql']
    expect(tokens[14]).toEqual value: ')', scopes: ['source.sql', 'punctuation.definition.section.bracket.round.end.sql']

  it 'tokenizes ,', ->
    {tokens} = grammar.tokenizeLine('name, year')
    expect(tokens[0]).toEqual value: 'name', scopes: ['source.sql']
    expect(tokens[1]).toEqual value: ',', scopes: ['source.sql', 'punctuation.separator.comma.sql']
    expect(tokens[2]).toEqual value: ' year', scopes: ['source.sql']

  it 'tokenizes .', ->
    {tokens} = grammar.tokenizeLine('.')
    expect(tokens[0]).toEqual value: '.', scopes: ['source.sql', 'punctuation.separator.period.sql']

    {tokens} = grammar.tokenizeLine('database.table')
    expect(tokens[0]).toEqual value: 'database', scopes: ['source.sql', 'constant.other.database-name.sql']
    expect(tokens[1]).toEqual value: '.', scopes: ['source.sql', 'punctuation.separator.period.sql']
    expect(tokens[2]).toEqual value: 'table', scopes: ['source.sql', 'constant.other.table-name.sql']

  it 'tokenizes ;', ->
    {tokens} = grammar.tokenizeLine('ORDER BY year;')
    expect(tokens[0]).toEqual value: 'ORDER BY', scopes: ['source.sql', 'keyword.other.DML.sql']
    expect(tokens[1]).toEqual value: ' year', scopes: ['source.sql']
    expect(tokens[2]).toEqual value: ';', scopes: ['source.sql', 'punctuation.terminator.statement.semicolon.sql']
