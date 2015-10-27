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

  it 'tokenizes numbers with decimals in them', ->
    {tokens} = grammar.tokenizeLine('123.45')
    expect(tokens[0]).toEqual value: '123.45', scopes: ['source.sql', 'constant.numeric.sql']

    {tokens} = grammar.tokenizeLine('123.')
    expect(tokens[0]).toEqual value: '123.', scopes: ['source.sql', 'constant.numeric.sql']

    {tokens} = grammar.tokenizeLine('.123')
    expect(tokens[0]).toEqual value: '.123', scopes: ['source.sql', 'constant.numeric.sql']

  it "quotes strings", ->
    {tokens} = grammar.tokenizeLine('"Test"')
    expect(tokens[0]).toEqual value: '"', scopes: ['source.sql', 'string.quoted.double.sql', 'punctuation.definition.string.begin.sql']
    expect(tokens[1]).toEqual value: 'Test', scopes: ['source.sql', 'string.quoted.double.sql']
    expect(tokens[2]).toEqual value: '"', scopes: ['source.sql', 'string.quoted.double.sql', 'punctuation.definition.string.end.sql']
    
