from py2neo import Graph

graph = Graph("bolt://localhost:7687", auth=("neo4j", "engx1494"))

cypher_query = """
MATCH (inquiry:Inquiry_1)
MATCH (imm)
WHERE imm.ManufacturerProductRoot = 'InjectionMoldingMachine'
WITH inquiry, imm,
  (inquiry.MinRequiredClampingForce <= imm.MaxClampingForce) AS OK1,
  (inquiry.ShotVolume <= imm.MaxPlasticizingCapacity) AS OK2,
  (inquiry.GreaterMoldDimension <= imm.GreaterClearDistanceBetweenColumns) AS OK3,
  (inquiry.SmallerMoldDimension <= imm.SmallerClearDistanceBetweenColumns) AS OK4,
  (inquiry.RequiredOpeningStroke <= imm.MaxOpeningStroke) AS OK5
RETURN imm.idShort AS idShort,
  CASE
    WHEN OK1 AND OK2 AND OK3 AND OK4 AND OK5 THEN 'is technically feasible'
    ELSE 'is not technically feasible'
  END AS feasibility
"""

result = graph.run(cypher_query).data()

for record in result:
    injection_molding_machine_idShort = record['idShort']
    feasibility = record['feasibility']
    print(f'{injection_molding_machine_idShort} {feasibility}')