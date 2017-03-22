//
//  RelationshipParsing.swift
//  EasyEway
//
//  Created by Beloizerov on 19.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

func <- (left: NSManagedObject, right: Any?) {
    guard let right = right else { return }
    left.parse(right)
}

func <- <T: NSManagedObject>(left: inout T?, right: JsonMap?) {
    guard let map = right else { return }
    left = T(entity: T.entity(), insertInto: map.context).parsed(map.wrapper)
}

func <- <T: NSManagedObject>(left: inout Set<T>, right: JsonMap?) {
    guard let map = right else { return }
    parse(set: &left, map: map)
}

func <- <T: NSManagedObject>(left: inout Set<T>?, right: JsonMap?) {
    guard let map = right else { return }
    var set = Set<T>()
    parse(set: &set, map: map)
    left = set
}

func <- <T: NSManagedObject>(left: inout [T], right: JsonMap?) {
    guard let map = right else { return }
    parse(array: &left, map: map)
}

func <- <T: NSManagedObject>(left: inout [T]?, right: JsonMap?) {
    guard let map = right else { return }
    var array = [T]()
    parse(array: &array, map: map)
    left = array
}

// MARK: - Private metodes

private func parse<T: NSManagedObject>(set: inout Set<T>, map: JsonMap) {
    guard let entity = entityDescription(map: map, type: T.self) else { return }
    if let jsonArray = map.array {
        for json in jsonArray {
            set.insert(T(entity: entity, insertInto: map.context).parsed(json))
        }
    } else if let json = map.dictionary {
        set.insert(T(entity: entity, insertInto: map.context).parsed(json))
    }
}

private func parse<T: NSManagedObject>(array: inout [T], map: JsonMap) {
    guard let entity = entityDescription(map: map, type: T.self) else { return }
    if let jsonArray = map.array {
        for json in jsonArray {
            array.append(T(entity: entity, insertInto: map.context).parsed(json))
        }
    } else if let jsonDictionary = map.dictionary {
        array.append(T(entity: entity, insertInto: map.context).parsed(jsonDictionary))
    }
}

private func entityDescription<T: NSManagedObject>(map: JsonMap, type: T.Type) -> NSEntityDescription? {
    if #available(iOS 10.0, *) {
        return T.entity()
    } else {
        let name = String(describing: type)
        return map.managedObject.entity.managedObjectModel.entitiesByName[name]
    }
}