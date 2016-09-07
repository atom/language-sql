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

  it 'tokenizes drop', ->
    {tokens} = grammar.tokenizeLine('DROP CONSTRAINT')
    expect(tokens[0]).toEqual value: 'DROP', scopes: ['source.sql', 'meta.drop.sql', 'keyword.other.create.sql']

  it 'tokenizes with', ->
    {tokens} = grammar.tokenizeLine('WITH field')
    expect(tokens[0]).toEqual value: 'WITH', scopes: ['source.sql', 'keyword.other.DML.sql']

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
