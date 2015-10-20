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

  it "quotes strings", ->
    {tokens} = grammar.tokenizeLine('"Test"')
    expect(tokens[0]).toEqual value: '"', scopes: ['source.sql', 'punctuation.definition.string.begin.sql']
    expect(tokens[1]).toEqual value: 'Test', scopes: ['source.sql', 'string.quoted.single.sql']
    expect(tokens[3]).toEqual value: '"', scopes: ['source.sql', 'punctuation.definition.string.end.sql']
    
    {tokens} = grammar.tokenizeLine('"Te\\"st"')
    expect(tokens[0]).toEqual value: '"', scopes: ['source.sql', 'punctuation.definition.string.begin.sql']
    expect(tokens[1]).toEqual value: 'Te"st', scopes: ['source.sql', 'string.quoted.single.sql']
    expect(tokens[3]).toEqual value: '"', scopes: ['source.sql', 'punctuation.definition.string.end.sql']
    
