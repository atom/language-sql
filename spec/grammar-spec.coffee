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
