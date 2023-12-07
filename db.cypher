// Creates a graph database schema 

MERGE (m:Mold)
SET m.caption = 'Mold'
SET m.idS = 'Mold'

MERGE (im:InjectionMoldingMachine)
SET im.caption = 'InjectionMoldingMachine'
SET im.idS = 'InjectionMoldingMachine'

MERGE (m)-[:isEquippedWith]->(im)   

MERGE (mi:MoldInsert)
SET mi.caption = 'MoldInsert'

MERGE (mi)-[:isEquippedWith]->(m)

MERGE (tcd:TemperatureControlUnit)
SET tcd.caption = 'TemperatureControlUnit'
SET tcd.idS = 'TemperatureControlUnit'

MERGE (d:Dryer)
SET d.caption = 'Dryer'

MERGE (hd:HandlingDevice)
SET hd.caption = 'HandlingDevice'
SET hd.idS = 'HandlingDevice'

MERGE (tc:TransportContainer)
SET tc.caption = 'TransportContainer'

MERGE (co:Conveyor)
SET co.caption = 'Conveyor'

MERGE (s:Scale)
SET s.caption = 'Scale'        

MERGE (ta:TechnicalAsset)
SET ta.caption = 'TechnicalAsset'
  
MERGE (im)-[:isA]->(ta)

MERGE (tcd)-[:isA]->(ta)

MERGE (d)-[:isA]->(ta)

MERGE (hd)-[:isA]->(ta)

MERGE (tc)-[:isA]->(ta)

MERGE (co)-[:isA]->(ta)

MERGE (s)-[:isA]->(ta)

MERGE (inq:Inquiry)
SET inq.caption = 'Inquiry'
SET inq.idS = 'Inquiry'

MERGE (inq)-[:checksTechnicalFeasibility]->(ta)

MERGE (sd:SalesDocument)
SET sd.caption = 'SalesDOcument'

MERGE (inq)-[:isA]->(sd)

MERGE (so:SalesOrder)
SET so.caption = 'SalesOrder'

MERGE (so)-[:isBuiltFrom]->(inq)

MERGE (po:ProductionOrder)
SET po.caption = 'ProductionOrder'

MERGE (po)-[:isConnectedTo]->(so)

MERGE (ps:ProductionSchedule)
SET ps.caption = 'ProductionSchedule'

MERGE (ps)-[:consistsOf]->(po)

MERGE (om:OptimizationModel)
SET om.caption = 'OptimizationModel'

MERGE (om)-[:optimizes]->(ps)

MERGE (pe:Person)
SET pe.caption = 'Person'

MERGE (pq:PersonalQualification)    
SET pq.caption = 'PersonalQualification'

MERGE (pe)-[:operatesAt]->(ta)

MERGE (pe)-[:has]->(pq)

MERGE (sc:ShiftCalendar)
SET sc.caption = 'ShiftCalendar'

MERGE (sc)-[:providesHighCapacity]->(ta)
MERGE (sc)-[:providesHighCapacity]->(pe) 

MERGE (p:Part)
SET p.caption = 'Part'

MERGE (r:Routing)
SET r.caption = 'Routing'  

MERGE (o:Operation)
SET o.caption = 'Operation'

MERGE (purO:PurchaseOrder)
SET purO.caption = 'PurchaseOrder'

MERGE (rm:RawMaterial)
SET rm.caption = 'RawMaterial'

MERGE (bom:BillOfMaterial)
SET bom.caption = 'BillOfMaterial'

MERGE (bp:BOMPosition)
SET bp.caption = 'BOMPosition'   

MERGE (id:InventoryData)
SET id.caption = 'InventoryData'  

MERGE (st:Storage)
SET st.caption = 'Storage'

MERGE (stp:StoragePosition)
SET stp.caption = 'StoragePosition'        

MERGE (pg:PlasticsGranulate)
SET pg.caption = 'PlasticsGranulate'  

MERGE (b:Batch)
SET b.caption = 'Batch'      

MERGE (po)-[:produces]->(p)

MERGE (po)-[:isSuborderOf]->(purO)

MERGE (purO)-[:delivers]->(rm)

MERGE (p)-[:consistsOf]->(rm)

MERGE (p)-[:consistsOf]->(r)

MERGE (p)-[:consistsOf]->(bom)

MERGE (r)-[:consistsOf]->(o)

MERGE (bom)-[:consistsOf]->(bp)

MERGE (pg)-[:isA]->(rm)

MERGE (b)-[:has]->(pg)

MERGE (st)-[:has]->(stp)

MERGE (id)-[:has]->(p)

MERGE (id)-[:has]->(bp)

MERGE (id)-[:has]->(st)

MERGE (bp)-[:isAssociatedWith]->(o)

MERGE (o)-[:isProcesseBy]->(td)




// The following queries fetch and structure data for some nodes in the graph db, 
including their submodels and technical details, 
and link them to a 'derivedFrom' node if they share the same property.


//TemperatureControlUnit_1


CALL apoc.load.json('http://localhost:51310/aas/TemperatureControlUnit_1?format=json') YIELD value
WITH value.AAS AS aas, value.Asset AS asset
MERGE (n:TemperatureControlUnit_1{idShort: asset.idShort})
SET n.submodels = [submodel IN aas.submodels | submodel.keys[0].value]

WITH n

CALL apoc.load.json('http://localhost:51310/aas/TemperatureControlUnit_1/submodels/Nameplate/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element
WHERE element.modelType.name = 'Property' OR element.modelType.name = 'MultiLanguageProperty'
WITH n, element,
  CASE
    WHEN element.modelType.name = 'MultiLanguageProperty' THEN element.value.langString[0].text
    ELSE element.value
  END AS propertyValue
SET n.derivedFrom = aas.derivedFrom.keys[0].value

WITH n

CALL apoc.load.json('http://localhost:51310/aas/TemperatureControlUnit_1/submodels/TechnicalData/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)
FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
    FOREACH (desc IN subElem.descriptions |
      SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
    )
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
      FOREACH (desc IN nestedSubElem.descriptions |
        SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
      )
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
        FOREACH (ts IN CASE WHEN deepNestedSubElem.idShort = 'TextStatement' THEN [deepNestedSubElem.value] ELSE [] END |
    SET n += apoc.map.fromPairs([ ['TextStatement', ts] ])
      )
    )
  )
)

WITH n

MATCH (n)
WHERE n.derivedFrom IS NOT NULL
MATCH (b)
WHERE b.idS IS NOT NULL AND n.derivedFrom = b.idS
WITH n, b LIMIT 1
CREATE (n)-[:IsA]->(b)

// Exclude 'de' and 'en properties from the final result

WITH n
SET n = apoc.map.clean(n, ['de', 'en'], [])


// TemperatureControlUnit_2


CALL apoc.load.json('http://localhost:51310/aas/TemperatureControlUnit_2?format=json') YIELD value
WITH value.AAS AS aas, value.Asset AS asset
MERGE (n:TemperatureControlUnit_2{idShort: asset.idShort})
SET n.derivedFrom = aas.derivedFrom.keys[0].value

WITH n

CALL apoc.load.json('http://localhost:51310/aas/TemperatureControlUnit_2/submodels/Nameplate/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element
WHERE element.modelType.name = 'Property' OR element.modelType.name = 'MultiLanguageProperty'
WITH n, element,
  CASE
    WHEN element.modelType.name = 'MultiLanguageProperty' THEN element.value.langString[0].text
    ELSE element.value
  END AS propertyValue
SET n += apoc.map.fromPairs([[element.idShort, propertyValue]])

WITH n

CALL apoc.load.json('http://localhost:51310/aas/TemperatureControlUnit_2/submodels/TechnicalData/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)
FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
    FOREACH (desc IN subElem.descriptions |
      SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
    )
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
      FOREACH (desc IN nestedSubElem.descriptions |
        SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
      )
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
        FOREACH (ts IN CASE WHEN deepNestedSubElem.idShort = 'TextStatement' THEN [deepNestedSubElem.value] ELSE [] END |
    SET n += apoc.map.fromPairs([ ['TextStatement', ts] ])
      )
    )
  )
)

WITH n

MATCH (n)
WHERE n.derivedFrom IS NOT NULL
MATCH (b)
WHERE b.idS IS NOT NULL AND n.derivedFrom = b.idS
WITH n, b LIMIT 1
CREATE (n)-[:IsA]->(b)

// Exclude 'de' and 'en properties from the final result

WITH n
SET n = apoc.map.clean(n, ['de', 'en'], [])



// Mold

CALL apoc.load.json('http://localhost:51310/aas/Mold?format=json') YIELD value
WITH value.AAS AS aas, value.Asset AS asset
MERGE (n:Mold_1{idShort: asset.idShort})
SET n.derivedFrom = aas.derivedFrom.keys[0].value

WITH n

CALL apoc.load.json('http://localhost:51310/aas/Mold/submodels/Nameplate/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element
WHERE element.modelType.name = 'Property' OR element.modelType.name = 'MultiLanguageProperty'
WITH n, element,
  CASE
    WHEN element.modelType.name = 'MultiLanguageProperty' THEN element.value.langString[0].text
    ELSE element.value
  END AS propertyValue
SET n += apoc.map.fromPairs([[element.idShort, propertyValue]])

WITH n

CALL apoc.load.json('http://localhost:51310/aas/Mold/submodels/TechnicalData/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)
FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
    FOREACH (desc IN subElem.descriptions |
      SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
    )
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
      FOREACH (desc IN nestedSubElem.descriptions |
        SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
      )
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
        FOREACH (ts IN CASE WHEN deepNestedSubElem.idShort = 'TextStatement' THEN [deepNestedSubElem.value] ELSE [] END |
    SET n += apoc.map.fromPairs([ ['TextStatement', ts] ])
      )
    )
  )
)

WITH n

MATCH (n)
WHERE n.derivedFrom IS NOT NULL
MATCH (b)
WHERE b.idS IS NOT NULL AND n.derivedFrom = b.idS
WITH n, b LIMIT 1
CREATE (n)-[:IsA]->(b)

// Exclude 'de' and 'en properties from the final result

WITH n
SET n = apoc.map.clean(n, ['de', 'en'], [])


// Inquiry_1

CALL apoc.load.json('http://localhost:51310/aas/Inquiry_1?format=json') YIELD value
WITH value.AAS AS aas, value.Asset AS asset
MERGE (n:Inquiry_1{idShort: asset.idShort})
SET n.derivedFrom = aas.derivedFrom.keys[0].value

WITH n

CALL apoc.load.json('http://localhost:51310/aas/Inquiry_1/submodels/Nameplate/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element
WHERE element.modelType.name = 'Property' OR element.modelType.name = 'MultiLanguageProperty'
WITH n, element,
  CASE
    WHEN element.modelType.name = 'MultiLanguageProperty' THEN element.value.langString[0].text
    ELSE element.value
  END AS propertyValue
SET n += apoc.map.fromPairs([[element.idShort, propertyValue]])

WITH n

CALL apoc.load.json('http://localhost:51310/aas/Inquiry_1/submodels/TechnicalData/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)
FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
    FOREACH (desc IN subElem.descriptions |
      SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
    )
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
      FOREACH (desc IN nestedSubElem.descriptions |
        SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
      )
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
        FOREACH (ts IN CASE WHEN deepNestedSubElem.idShort = 'TextStatement' THEN [deepNestedSubElem.value] ELSE [] END |
    SET n += apoc.map.fromPairs([ ['TextStatement', ts] ])
      )
    )
  )
)

WITH n

CALL apoc.load.json('http://localhost:51310/aas/Inquiry_1/submodels/Specifications/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)

FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
    )
  )
)

WITH n

MATCH (n)
WHERE n.derivedFrom IS NOT NULL
MATCH (b)
WHERE b.idS IS NOT NULL AND n.derivedFrom = b.idS
WITH n, b LIMIT 1
CREATE (n)-[:IsA]->(b)

// Exclude 'de' and 'en properties from the final result

WITH n
SET n = apoc.map.clean(n, ['de', 'en'], [])


// HandlingDevice_1


CALL apoc.load.json('http://localhost:51310/aas/HandlingDevice_1?format=json') YIELD value
WITH value.AAS AS aas, value.Asset AS asset
MERGE (n:HandlingDevice_1{idShort: asset.idShort})
SET n.derivedFrom = aas.derivedFrom.keys[0].value

WITH n

CALL apoc.load.json('http://localhost:51310/aas/HandlingDevice_1/submodels/Nameplate/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element
WHERE element.modelType.name = 'Property' OR element.modelType.name = 'MultiLanguageProperty'
WITH n, element,
  CASE
    WHEN element.modelType.name = 'MultiLanguageProperty' THEN element.value.langString[0].text
    ELSE element.value
  END AS propertyValue
SET n += apoc.map.fromPairs([[element.idShort, propertyValue]])

WITH n

CALL apoc.load.json('http://localhost:51310/aas/HandlingDevice_1/submodels/TechnicalData/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)
FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
    FOREACH (desc IN subElem.descriptions |
      SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
    )
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
      FOREACH (desc IN nestedSubElem.descriptions |
        SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
      )
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
        FOREACH (ts IN CASE WHEN deepNestedSubElem.idShort = 'TextStatement' THEN [deepNestedSubElem.value] ELSE [] END |
    SET n += apoc.map.fromPairs([ ['TextStatement', ts] ])
      )
    )
  )
)

WITH n

MATCH (n)
WHERE n.derivedFrom IS NOT NULL
MATCH (b)
WHERE b.idS IS NOT NULL AND n.derivedFrom = b.idS
WITH n, b LIMIT 1
CREATE (n)-[:IsA]->(b)

// Exclude 'de' and 'en properties from the final result

WITH n
SET n = apoc.map.clean(n, ['de', 'en'], [])


// HandlingDevice_2


CALL apoc.load.json('http://localhost:51310/aas/HandlingDevice_2?format=json') YIELD value
WITH value.AAS AS aas, value.Asset AS asset
MERGE (n:HandlingDevice_2{idShort: asset.idShort})
SET n.derivedFrom = aas.derivedFrom.keys[0].value

WITH n

CALL apoc.load.json('http://localhost:51310/aas/HandlingDevice_2/submodels/Nameplate/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element
WHERE element.modelType.name = 'Property' OR element.modelType.name = 'MultiLanguageProperty'
WITH n, element,
  CASE
    WHEN element.modelType.name = 'MultiLanguageProperty' THEN element.value.langString[0].text
    ELSE element.value
  END AS propertyValue
SET n += apoc.map.fromPairs([[element.idShort, propertyValue]])

WITH n

CALL apoc.load.json('http://localhost:51310/aas/HandlingDevice_2/submodels/TechnicalData/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)
FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
    FOREACH (desc IN subElem.descriptions |
      SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
    )
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
      FOREACH (desc IN nestedSubElem.descriptions |
        SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
      )
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
        FOREACH (ts IN CASE WHEN deepNestedSubElem.idShort = 'TextStatement' THEN [deepNestedSubElem.value] ELSE [] END |
    SET n += apoc.map.fromPairs([ ['TextStatement', ts] ])
      )
    )
  )
)

WITH n

MATCH (n)
WHERE n.derivedFrom IS NOT NULL
MATCH (b)
WHERE b.idS IS NOT NULL AND n.derivedFrom = b.idS
WITH n, b LIMIT 1
CREATE (n)-[:IsA]->(b)

// Exclude 'de' and 'en properties from the final result

WITH n
SET n = apoc.map.clean(n, ['de', 'en'], [])


// IMM_1


CALL apoc.load.json('http://localhost:51310/aas/IMM_1?format=json') YIELD value
WITH value.AAS AS aas, value.Asset AS asset
MERGE (n:InjectionMoldingMachine_1{idShort: asset.idShort})
SET n.derivedFrom = aas.derivedFrom.keys[0].value

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_1/submodels/Nameplate/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element
WHERE element.modelType.name = 'Property' OR element.modelType.name = 'MultiLanguageProperty'
WITH n, element,
  CASE
    WHEN element.modelType.name = 'MultiLanguageProperty' THEN element.value.langString[0].text
    ELSE element.value
  END AS propertyValue
SET n += apoc.map.fromPairs([[element.idShort, propertyValue]])

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_1/submodels/TechnicalData/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)
FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
    FOREACH (desc IN subElem.descriptions |
      SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
    )
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
      FOREACH (desc IN nestedSubElem.descriptions |
        SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
      )
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
        FOREACH (ts IN CASE WHEN deepNestedSubElem.idShort = 'TextStatement' THEN [deepNestedSubElem.value] ELSE [] END |
    SET n += apoc.map.fromPairs([ ['TextStatement', ts] ])
      )
    )
  )
)

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_1/submodels/SetupPeriphery/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)

FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
    )
  )
)

WITH n

MATCH (n)
WHERE n.derivedFrom IS NOT NULL
MATCH (b)
WHERE b.idS IS NOT NULL AND n.derivedFrom = b.idS
WITH n, b LIMIT 1
CREATE (n)-[:IsA]->(b)

// Exclude 'de' and 'en properties from the final result

WITH n
SET n = apoc.map.clean(n, ['de', 'en'], [])


// IMM_2

CALL apoc.load.json('http://localhost:51310/aas/IMM_2?format=json') YIELD value
WITH value.AAS AS aas, value.Asset AS asset
MERGE (n:InjectionMoldingMachine_2{idShort: asset.idShort})
SET n.derivedFrom = aas.derivedFrom.keys[0].value

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_2/submodels/Nameplate/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element
WHERE element.modelType.name = 'Property' OR element.modelType.name = 'MultiLanguageProperty'
WITH n, element,
  CASE
    WHEN element.modelType.name = 'MultiLanguageProperty' THEN element.value.langString[0].text
    ELSE element.value
  END AS propertyValue
SET n += apoc.map.fromPairs([[element.idShort, propertyValue]])

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_2/submodels/TechnicalData/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)
FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
    FOREACH (desc IN subElem.descriptions |
      SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
    )
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
      FOREACH (desc IN nestedSubElem.descriptions |
        SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
      )
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
        FOREACH (ts IN CASE WHEN deepNestedSubElem.idShort = 'TextStatement' THEN [deepNestedSubElem.value] ELSE [] END |
    SET n += apoc.map.fromPairs([ ['TextStatement', ts] ])
      )
    )
  )
)

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_2/submodels/SetupPeriphery/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)

FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
    )
  )
)

WITH n

MATCH (n)
WHERE n.derivedFrom IS NOT NULL
MATCH (b)
WHERE b.idS IS NOT NULL AND n.derivedFrom = b.idS
WITH n, b LIMIT 1
CREATE (n)-[:IsA]->(b)

// Exclude 'de' and 'en properties from the final result

WITH n
SET n = apoc.map.clean(n, ['de', 'en'], [])


// IMM_3


CALL apoc.load.json('http://localhost:51310/aas/IMM_3?format=json') YIELD value
WITH value.AAS AS aas, value.Asset AS asset
MERGE (n:InjectionMoldingMachine_3{idShort: asset.idShort})
SET n.derivedFrom = aas.derivedFrom.keys[0].value

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_3/submodels/Nameplate/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element
WHERE element.modelType.name = 'Property' OR element.modelType.name = 'MultiLanguageProperty'
WITH n, element,
  CASE
    WHEN element.modelType.name = 'MultiLanguageProperty' THEN element.value.langString[0].text
    ELSE element.value
  END AS propertyValue
SET n += apoc.map.fromPairs([[element.idShort, propertyValue]])

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_3/submodels/TechnicalData/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)
FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
    FOREACH (desc IN subElem.descriptions |
      SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
    )
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
      FOREACH (desc IN nestedSubElem.descriptions |
        SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
      )
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
        FOREACH (ts IN CASE WHEN deepNestedSubElem.idShort = 'TextStatement' THEN [deepNestedSubElem.value] ELSE [] END |
    SET n += apoc.map.fromPairs([ ['TextStatement', ts] ])
      )
    )
  )
)

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_3/submodels/SetupPeriphery/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)

FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
    )
  )
)

WITH n

MATCH (n)
WHERE n.derivedFrom IS NOT NULL
MATCH (b)
WHERE b.idS IS NOT NULL AND n.derivedFrom = b.idS
WITH n, b LIMIT 1
CREATE (n)-[:IsA]->(b)

// Exclude 'de' and 'en properties from the final result

WITH n
SET n = apoc.map.clean(n, ['de', 'en'], [])


// IMM_4

CALL apoc.load.json('http://localhost:51310/aas/IMM_4?format=json') YIELD value
WITH value.AAS AS aas, value.Asset AS asset
MERGE (n:InjectionMoldingMachine_4{idShort: asset.idShort})
SET n.derivedFrom = aas.derivedFrom.keys[0].value

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_4/submodels/Nameplate/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element
WHERE element.modelType.name = 'Property' OR element.modelType.name = 'MultiLanguageProperty'
WITH n, element,
  CASE
    WHEN element.modelType.name = 'MultiLanguageProperty' THEN element.value.langString[0].text
    ELSE element.value
  END AS propertyValue
SET n += apoc.map.fromPairs([[element.idShort, propertyValue]])

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_4/submodels/TechnicalData/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)
FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
    FOREACH (desc IN subElem.descriptions |
      SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
    )
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
      FOREACH (desc IN nestedSubElem.descriptions |
        SET n += apoc.map.fromPairs([ [desc.language, desc.text] ])
      )
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
        FOREACH (ts IN CASE WHEN deepNestedSubElem.idShort = 'TextStatement' THEN [deepNestedSubElem.value] ELSE [] END |
    SET n += apoc.map.fromPairs([ ['TextStatement', ts] ])
      )
    )
  )
)

WITH n

CALL apoc.load.json('http://localhost:51310/aas/IMM_4/submodels/SetupPeriphery/complete?format=json') YIELD value
WITH value.submodelElements AS elements, n
UNWIND elements AS element
WITH n, element,
  CASE
    WHEN element.modelType.name = 'Property' THEN [element]
    ELSE []
  END AS properties,
  CASE
    WHEN element.modelType.name = 'SubmodelElementCollection' THEN element.value
    ELSE []
  END AS subElements

FOREACH (prop IN properties |
  SET n += apoc.map.fromPairs([ [prop.idShort, prop.value] ])
)

FOREACH (subElem IN subElements |
  FOREACH (_ IN CASE WHEN subElem.modelType.name = 'Property' THEN [1] ELSE [] END |
    SET n += apoc.map.fromPairs([[subElem.idShort, subElem.value]])
  )
  FOREACH (nestedSubElem IN CASE WHEN subElem.modelType.name = 'SubmodelElementCollection' THEN subElem.value ELSE [] END |
    FOREACH (_ IN CASE WHEN nestedSubElem.modelType.name = 'Property' THEN [1] ELSE [] END |
      SET n += apoc.map.fromPairs([[nestedSubElem.idShort, nestedSubElem.value]])
    )
    FOREACH (deepNestedSubElem IN CASE WHEN nestedSubElem.modelType.name = 'SubmodelElementCollection' THEN nestedSubElem.value ELSE [] END |
      SET n += apoc.map.fromPairs([[deepNestedSubElem.idShort, deepNestedSubElem.value]])
    )
  )
)

WITH n

MATCH (n)
WHERE n.derivedFrom IS NOT NULL
MATCH (b)
WHERE b.idS IS NOT NULL AND n.derivedFrom = b.idS
WITH n, b LIMIT 1
CREATE (n)-[:IsA]->(b)

// Exclude 'de' and 'en properties from the final result

WITH n
SET n = apoc.map.clean(n, ['de', 'en'], [])


// Retrieve and return all nodes from the graph database without any specific filtering or conditions

MATCH (n)
RETURN n




