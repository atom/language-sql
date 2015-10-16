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
    
  it 'tokenizes integers', ->
    {tokens} = grammar.tokenizeLine('12345')
    expect(tokens[0]).toEqual value: '12345', scopes: ['constant.numeric.sql']
  
  it 'tokenizes decimal numbers', ->
    {tokens} = grammar.tokenizeLine('123.45')
    expect(tokens[0]).toEqual value: '123.45', scopes: ['constant.numeric.sql']
