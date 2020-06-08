//
//  DataManager.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/22.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import Foundation
import FMDB

class DataManager {
    
    static let share = DataManager()
    private var queue : FMDatabaseQueue!
    
    private init(){
        let searchPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = searchPaths[0]
        let path = documentPath + "/ItemFinder.db"
        print("*******" + path)
        
        if !FileManager.default.fileExists(atPath: path) {
            let projDbPath = Bundle.main.path(forResource: "ItemFinder.db", ofType: nil)
            do {
               try FileManager.default.copyItem(atPath: projDbPath!, toPath: path)
            } catch {
                print(error)
            }
        }
        
        queue = FMDatabaseQueue(path: path)

    }
    
    
    func addGroup(group: Group) -> Bool {
        var success = false
        let sequence = getMaxSequenceOfGroup() + 1
        if sequence >= 1 {
            queue.inDatabase { (db) in
                success = db.executeUpdate("INSERT INTO tb_group (name,create_time,sequence,delete_status) VALUES (?,?,?,?)", withArgumentsIn: [group.name!,NSNumber(value: group.create_time!),NSNumber(value: sequence),NSNumber(value: 0)])
            }
        }
        return success
    }
    
    func addSpace(space: Space) -> Bool {
        var success = false
        let sequence = getMaxSequenceOfSpace() + 1
        if sequence >= 1 {
            queue.inDatabase { (db) in
                success = db.executeUpdate("INSERT INTO tb_space (name,create_time,sequence,delete_status,pic_url,pic_width,pic_height) VALUES (?,?,?,?,?,?,?)", withArgumentsIn: [space.name!,NSNumber(value: space.create_time!),NSNumber(value: sequence),NSNumber(value: 0),space.pic_url!,NSNumber(value: space.pic_width!),NSNumber(value: space.pic_height!)])
            }
        }
        return success
    }
    
    
    func addItem(item: Item) -> Bool {
        var success = false
        let sequence = getMaxSequenceOfItem() + 1
        let sequence_group = getMaxSequenceOfItemInGroup(group_id: item.group_id) + 1
        let sequence_space = getMaxSequenceOfItemInSpace(space_id: item.space_id) + 1
        
        if sequence >= 1 {
            queue.inDatabase { (db) in
                success = db.executeUpdate("INSERT INTO tb_item (description,create_time,sequence,delete_status,pic_url,pic_width,pic_height,group_id,sequence_group,space_id,sequence_space) VALUES (?,?,?,?,?,?,?,?,?,?,?)", withArgumentsIn: [item.description!,NSNumber(value: item.create_time!),NSNumber(value: sequence),NSNumber(value: 0),item.pic_url!,NSNumber(value: item.pic_width!),NSNumber(value: item.pic_height!),NSNumber(value: item.group_id ?? 0),NSNumber(value: sequence_group),NSNumber(value: item.space_id ?? 0),NSNumber(value: sequence_space)])
            }
        }
        return success
    }
    
    
    private func getMaxSequenceOfGroup() ->Int32{
        var sequence: Int32 = -1
        queue.inDatabase { (db) in
            do {
                let ret = try db.executeQuery("SELECT MAX(sequence) FROM tb_group", values: nil)
                while ret.next(){
                    sequence = ret.int(forColumnIndex: 0)
                }
            } catch{
                print(error)
            }
        }
        return sequence
    }
    
    private func getMaxSequenceOfSpace() ->Int32{
        var sequence: Int32 = -1
        queue.inDatabase { (db) in
            do {
                let ret = try db.executeQuery("SELECT MAX(sequence) FROM tb_space", values: nil)
                while ret.next(){
                    sequence = ret.int(forColumnIndex: 0)
                }
            } catch{
                print(error)
            }
        }
        return sequence
    }
    
    private func getMaxSequenceOfItem() ->Int32{
        var sequence: Int32 = -1
        queue.inDatabase { (db) in
            do {
                let ret = try db.executeQuery("SELECT MAX(sequence) FROM tb_item", values: nil)
                while ret.next(){
                    sequence = ret.int(forColumnIndex: 0)
                }
            } catch{
                print(error)
            }
        }
        return sequence
    }
    
    func getMaxSequenceOfItemInGroup(group_id:Int32?) ->Int32{
        var sequence: Int32 = -1
        if let gid = group_id {
            queue.inDatabase { (db) in
                do {
                    let ret = try db.executeQuery("SELECT MAX(sequence_group) FROM tb_item WHERE group_id = ?", values: [gid])
                    while ret.next(){
                        sequence = ret.int(forColumnIndex: 0)
                    }
                } catch{
                    print(error)
                }
            }
            
        }else{
            sequence = 0
        }
        return sequence
    }
    
    func getMaxSequenceOfItemInSpace(space_id:Int32?) ->Int32{
        var sequence: Int32 = -1
        if let sid = space_id {
            queue.inDatabase { (db) in
                do {
                    let ret = try db.executeQuery("SELECT MAX(sequence_space) FROM tb_item WHERE space_id = ?", values: [sid])
                    while ret.next(){
                        sequence = ret.int(forColumnIndex: 0)
                    }
                } catch{
                    print(error)
                }
            }
        }else{
            sequence = 0
        }
        return sequence
    }
    

    func getGroups(keyword: String = "",edit: Bool = false) -> [Group] {
        var groups = [Group]()
        queue.inDatabase { (db) in
            var ret : FMResultSet
            if keyword.count > 0{
                let sqlStr = String(format: "SELECT * FROM tb_group WHERE name LIKE '%%%@%%' ORDER BY sequence DESC", keyword)
                ret = db.executeQuery(sqlStr, withArgumentsIn: [])!
            }else{
                ret = db.executeQuery("SELECT * FROM tb_group ORDER BY sequence DESC", withArgumentsIn: [])!
            }

            while ret.next(){
                var group = Group()
                group.id = ret.int(forColumn: "id")
                group.name = ret.string(forColumn: "name")
                group.create_time = ret.int(forColumn: "create_time")
                group.sequence = ret.int(forColumn: "sequence")
                groups.append(group)
            }
        }
        
        if keyword.count == 0 && edit == false {
            var undefineGroup = Group()
            undefineGroup.id = 0
            undefineGroup.name = "No Group"
            undefineGroup.create_time = 0
            undefineGroup.sequence = getMaxSequenceOfGroup() + 1
            groups.insert(undefineGroup, at: 0)
        }
        
        queue.inDatabase { (db) in
            for i in 0..<groups.count {
                //var group = groups[i]  struct赋值是copy一份完整相同的內容给另一個变量 
                var items = [Item]()
                do {
                    let ret = try db.executeQuery("SELECT * FROM tb_item WHERE group_id = ? ORDER BY sequence_group DESC", values: [groups[i].id!])
                    while ret.next(){
                        var item = Item()
                        item.id = ret.int(forColumn: "id")
                        item.description = ret.string(forColumn: "description")
                        item.pic_url = ret.string(forColumn: "pic_url")
                        item.pic_width = ret.int(forColumn: "pic_width")
                        item.pic_height = ret.int(forColumn: "pic_height")
                        item.sequence = ret.int(forColumn: "sequence")
                        item.create_time = ret.int(forColumn: "create_time")
                        item.group_id = ret.int(forColumn: "group_id")
                        item.sequence_group = ret.int(forColumn: "sequence_group")
                        item.space_id = ret.int(forColumn: "space_id")
                        item.sequence_space = ret.int(forColumn: "sequence_space")
                        items.append(item)
                    }
                } catch{
                    print(error)
                }
                
                groups[i].items = items
            }

        }
        
        if groups.count > 0 && groups[0].id == 0 && groups[0].items!.count == 0 {
            groups.remove(at: 0)
        }
        return groups
    }
    
    func getSpaces(keyword : String = "",edit: Bool = false) -> [Space] {
        var spaces = [Space]()
        queue.inDatabase { (db) in
            var ret : FMResultSet
            if keyword.count > 0{
                let sqlStr = String(format: "SELECT * FROM tb_space WHERE name LIKE '%%%@%%' ORDER BY sequence DESC", keyword)
                ret = db.executeQuery(sqlStr, withArgumentsIn: [])!
            }else{
                ret = db.executeQuery("SELECT * FROM tb_space ORDER BY sequence DESC", withArgumentsIn: [])!
            }
            
            while ret.next(){
                var space = Space()
                space.id = ret.int(forColumn: "id")
                space.name = ret.string(forColumn: "name")
                space.create_time = ret.int(forColumn: "create_time")
                space.sequence = ret.int(forColumn: "sequence")
                space.pic_url = ret.string(forColumn: "pic_url")
                space.pic_width = ret.int(forColumn: "pic_width")
                space.pic_height = ret.int(forColumn: "pic_height")
                spaces.append(space)
            }
        }
        
        if keyword.count == 0 && edit == false {
            var undefineSpace = Space()
            undefineSpace.id = 0
            undefineSpace.name = "无空间"
            undefineSpace.pic_url = "http://aso-cos-1259131898.cos.ap-beijing.myqcloud.com/ios/-854449090.jpg"
            undefineSpace.pic_width = 828
            undefineSpace.pic_height = 828
            undefineSpace.create_time = 0
            undefineSpace.sequence = getMaxSequenceOfSpace() + 1
            spaces.insert(undefineSpace, at: 0)
        }
        
        queue.inDatabase { (db) in
            for i in 0..<spaces.count {
                do {
                    let ret = try db.executeQuery("SELECT COUNT(*) FROM tb_item WHERE space_id = ?", values: [spaces[i].id!])
                    while ret.next(){
                        let count = ret.int(forColumnIndex: 0)
                        spaces[i].itemCount = count
                    }
                } catch{
                    print(error)
                }
            }
        }
        
        if spaces.count > 0 && spaces[0].id == 0 && spaces[0].itemCount == 0 {
            spaces.remove(at: 0)
        }
        
        return spaces
    }
    
    
    func getItemsInGroup(group_id : Int32) -> [Item] {
        var items = [Item]()
        queue.inDatabase { (db) in
            let ret = db.executeQuery("SELECT ti.*,tg.name AS group_name,ts.name AS space_name FROM tb_item ti LEFT JOIN tb_group tg ON ti.group_id = tg.id LEFT JOIN tb_space  ts ON ti.space_id = ts.id WHERE group_id = ? ORDER BY sequence_group DESC", withArgumentsIn: [NSNumber(value: group_id)])!
            while ret.next(){
                var item = Item()
                item.id = ret.int(forColumn: "id")
                item.description = ret.string(forColumn: "description")
                item.create_time = ret.int(forColumn: "create_time")
                item.sequence = ret.int(forColumn: "sequence")
                item.pic_url = ret.string(forColumn: "pic_url")
                item.pic_width = ret.int(forColumn: "pic_width")
                item.pic_height = ret.int(forColumn: "pic_height")
                item.group_id = ret.int(forColumn: "group_id")
                item.sequence_group = ret.int(forColumn: "sequence_group")
                item.space_id = ret.int(forColumn: "space_id")
                item.sequence_space = ret.int(forColumn: "sequence_space")
                item.group_name = ret.string(forColumn: "group_name")
                item.space_name = ret.string(forColumn: "space_name")
                items.append(item)
            }
        }
        return items
    }
    
    func getItemsInSpace(space_id : Int32) -> [Item] {
        var items = [Item]()
        queue.inDatabase { (db) in
            let ret = db.executeQuery("SELECT ti.*,tg.name AS group_name,ts.name AS space_name FROM tb_item ti LEFT JOIN tb_group tg ON ti.group_id = tg.id LEFT JOIN tb_space  ts ON ti.space_id = ts.id WHERE space_id = ? ORDER BY sequence_space DESC", withArgumentsIn: [NSNumber(value: space_id)])!
            while ret.next(){
                var item = Item()
                item.id = ret.int(forColumn: "id")
                item.description = ret.string(forColumn: "description")
                item.create_time = ret.int(forColumn: "create_time")
                item.sequence = ret.int(forColumn: "sequence")
                item.pic_url = ret.string(forColumn: "pic_url")
                item.pic_width = ret.int(forColumn: "pic_width")
                item.pic_height = ret.int(forColumn: "pic_height")
                item.group_id = ret.int(forColumn: "group_id")
                item.sequence_group = ret.int(forColumn: "sequence_group")
                item.space_id = ret.int(forColumn: "space_id")
                item.sequence_space = ret.int(forColumn: "sequence_space")
                item.group_name = ret.string(forColumn: "group_name")
                item.space_name = ret.string(forColumn: "space_name")
                items.append(item)
            }
        }
        return items
    }
    
    
    func getItems(keyword : String = "") -> [Item] {
        var items = [Item]()
        queue.inDatabase { (db) in
            var ret : FMResultSet
            if keyword.count > 0{
                let sqlStr = String(format: "SELECT ti.*,tg.name AS group_name,ts.name AS space_name FROM tb_item ti LEFT JOIN tb_group tg ON ti.group_id = tg.id LEFT JOIN tb_space  ts ON ti.space_id = ts.id WHERE ti.description LIKE '%%%@%%' ORDER BY sequence DESC", keyword)
//                let sqlStr = String(format: "SELECT * FROM tb_item WHERE description LIKE '%%%@%%' ORDER BY sequence DESC", keyword)
                ret = db.executeQuery(sqlStr, withArgumentsIn: [])!
            }else{
                ret = db.executeQuery("SELECT ti.*,tg.name AS group_name,ts.name AS space_name FROM tb_item ti LEFT JOIN tb_group tg ON ti.group_id = tg.id LEFT JOIN tb_space  ts ON ti.space_id = ts.id ORDER BY sequence DESC", withArgumentsIn: [])!
            }
            while ret.next(){
                var item = Item()
                item.id = ret.int(forColumn: "id")
                item.description = ret.string(forColumn: "description")
                item.create_time = ret.int(forColumn: "create_time")
                item.sequence = ret.int(forColumn: "sequence")
                item.pic_url = ret.string(forColumn: "pic_url")
                item.pic_width = ret.int(forColumn: "pic_width")
                item.pic_height = ret.int(forColumn: "pic_height")
                item.group_id = ret.int(forColumn: "group_id")
                item.sequence_group = ret.int(forColumn: "sequence_group")
                item.space_id = ret.int(forColumn: "space_id")
                item.sequence_space = ret.int(forColumn: "sequence_space")
                item.group_name = ret.string(forColumn: "group_name")
                item.space_name = ret.string(forColumn: "space_name")
                items.append(item)
            }
        }
        return items
    }
    
    
    func updateItem(item : Item) -> Bool {
        var success = false
        queue.inDatabase { (db) in
            success = db.executeUpdate("UPDATE tb_item SET description = ?,pic_url = ?,pic_width = ?,pic_height = ?,create_time = ?,sequence = ?,group_id = ?,sequence_group = ?,space_id = ?,sequence_space = ? WHERE id = ?", withArgumentsIn: [item.description!,item.pic_url!,NSNumber(value: item.pic_width!),NSNumber(value: item.pic_height!),NSNumber(value: item.create_time!),NSNumber(value: item.sequence!),NSNumber(value: item.group_id!),NSNumber(value: item.sequence_group!),NSNumber(value: item.space_id!),NSNumber(value: item.sequence_space!),NSNumber(value: item.id!)])

        }
        return success
    }
    
    func getItem(item_id : Int32) -> Item {
        var item = Item()
        queue.inDatabase { (db) in
            let ret = db.executeQuery("SELECT ti.*,tg.name AS group_name,ts.name AS space_name FROM tb_item ti LEFT JOIN tb_group tg ON ti.group_id = tg.id LEFT JOIN tb_space ts ON ti.space_id = ts.id WHERE ti.id = ?", withArgumentsIn: [item_id])!
            while ret.next(){
                item.id = ret.int(forColumn: "id")
                item.description = ret.string(forColumn: "description")
                item.create_time = ret.int(forColumn: "create_time")
                item.sequence = ret.int(forColumn: "sequence")
                item.pic_url = ret.string(forColumn: "pic_url")
                item.pic_width = ret.int(forColumn: "pic_width")
                item.pic_height = ret.int(forColumn: "pic_height")
                item.group_id = ret.int(forColumn: "group_id")
                item.sequence_group = ret.int(forColumn: "sequence_group")
                item.space_id = ret.int(forColumn: "space_id")
                item.sequence_space = ret.int(forColumn: "sequence_space")
                item.group_name = ret.string(forColumn: "group_name")
                item.space_name = ret.string(forColumn: "space_name")
            }
        }
        return item
    }
    
    func deleteItem(item_id : Int32) -> Bool {
        var success = false
        queue.inDatabase { (db) in
            success = db.executeUpdate("DELETE FROM tb_item WHERE id = ?", withArgumentsIn: [NSNumber(value: item_id)])
        }
        return success
    }
    
    func updateGroup(group: Group) -> Bool {
        var success = false
        queue.inDatabase { (db) in
            success = db.executeUpdate("UPDATE tb_group SET name = ? WHERE id = ?", withArgumentsIn: [group.name!,NSNumber(value: group.id!)])
        }
        return success
    }
    
    func deleteGroup(group_id : Int32) -> Bool {
        var success = false
        var itemsInGroup = [Item]()
        queue.inDatabase { (db) in
            let ret = db.executeQuery("SELECT * FROM tb_item WHERE group_id = ? ORDER BY sequence_group", withArgumentsIn: [NSNumber(value: group_id)])!
            while ret.next(){
                var item = Item()
                item.id = ret.int(forColumn: "id")
                item.description = ret.string(forColumn: "description")
                item.create_time = ret.int(forColumn: "create_time")
                item.sequence = ret.int(forColumn: "sequence")
                item.pic_url = ret.string(forColumn: "pic_url")
                item.pic_width = ret.int(forColumn: "pic_width")
                item.pic_height = ret.int(forColumn: "pic_height")
                item.group_id = ret.int(forColumn: "group_id")
                item.sequence_group = ret.int(forColumn: "sequence_group")
                item.space_id = ret.int(forColumn: "space_id")
                item.sequence_space = ret.int(forColumn: "sequence_space")
                itemsInGroup.append(item)
            }
        }
        
        
        let baseSequence = getMaxSequenceOfItemInGroup(group_id: 0) + 1
        
        queue.inTransaction { (db, rollback) in
            do {
                for i in 0..<itemsInGroup.count{
                    let item = itemsInGroup[i]
                    try db.executeUpdate("UPDATE tb_item SET group_id = 0, sequence_group = ? WHERE id = ?", values: [baseSequence + Int32(i),item.id!])
                }
                
                try db.executeUpdate("DELETE FROM tb_group WHERE id = ?", values: [group_id])
                success = true
    
            } catch {
                rollback.pointee = true
                success = false
            }
        }
        
        return success
    }
    
    
    func updateSpace(space: Space) -> Bool {
        var success = false
        queue.inDatabase { (db) in
            success = db.executeUpdate("UPDATE tb_space SET name = ?, pic_url = ?,pic_width = ?,pic_height = ? WHERE id = ?", withArgumentsIn: [space.name!,space.pic_url!,NSNumber(value: space.pic_width!),NSNumber(value: space.pic_height!),NSNumber(value: space.id!)])
        }
        return success
    }
    
    
    func deleteSpace(space_id : Int32) -> Bool {
        var success = false
        var itemsInSpace = [Item]()
        queue.inDatabase { (db) in
            let ret = db.executeQuery("SELECT * FROM tb_item WHERE space_id = ? ORDER BY sequence_space", withArgumentsIn: [NSNumber(value: space_id)])!
            while ret.next(){
                var item = Item()
                item.id = ret.int(forColumn: "id")
                item.description = ret.string(forColumn: "description")
                item.create_time = ret.int(forColumn: "create_time")
                item.sequence = ret.int(forColumn: "sequence")
                item.pic_url = ret.string(forColumn: "pic_url")
                item.pic_width = ret.int(forColumn: "pic_width")
                item.pic_height = ret.int(forColumn: "pic_height")
                item.group_id = ret.int(forColumn: "group_id")
                item.sequence_group = ret.int(forColumn: "sequence_group")
                item.space_id = ret.int(forColumn: "space_id")
                item.sequence_space = ret.int(forColumn: "sequence_space")
                itemsInSpace.append(item)
            }
        }
        
        
        let baseSequence = getMaxSequenceOfItemInSpace(space_id: 0) + 1
        
        queue.inTransaction { (db, rollback) in
            do {
                for i in 0..<itemsInSpace.count{
                    let item = itemsInSpace[i]
                    try db.executeUpdate("UPDATE tb_item SET space_id = 0, sequence_space = ? WHERE id = ?", values: [baseSequence + Int32(i),item.id!])
                }
                
                try db.executeUpdate("DELETE FROM tb_space WHERE id = ?", values: [space_id])
                success = true
                
            } catch {
                rollback.pointee = true
                success = false
            }
        }
        
        return success
    }

    
    func updateGroupsSequence(groups:[Group]) -> Bool {
        var success = false
        queue.inTransaction { (db, rollback) in
            do {
                for i in 0..<groups.count{
                    let group = groups[i]
                    try db.executeUpdate("UPDATE tb_group SET sequence = ? WHERE id = ?", values: [groups.count - i,group.id!])
                }
                success = true
            } catch {
                rollback.pointee = true
                success = false
            }
        }
        
        return success
    }
    
    func updateSpacesSequence(spaces:[Space]) -> Bool {
        var success = false
        queue.inTransaction { (db, rollback) in
            do {
                for i in 0..<spaces.count{
                    let space = spaces[i]
                    try db.executeUpdate("UPDATE tb_space SET sequence = ? WHERE id = ?", values: [spaces.count - i,space.id!])
                }
                success = true
            } catch {
                rollback.pointee = true
                success = false
            }
        }
        
        return success
    }
    
    func updateItemsSequence(items:[Item]) -> Bool {
        var success = false
        queue.inTransaction { (db, rollback) in
            do {
                for i in 0..<items.count{
                    let item = items[i]
                    try db.executeUpdate("UPDATE tb_item SET sequence = ? WHERE id = ?", values: [items.count - i,item.id!])
                }
                success = true
            } catch {
                rollback.pointee = true
                success = false
            }
        }
        
        return success
    }
    
    func updateItemsSequenceInGroup(items:[Item]) -> Bool {
        var success = false
        queue.inTransaction { (db, rollback) in
            do {
                for i in 0..<items.count{
                    let item = items[i]
                    try db.executeUpdate("UPDATE tb_item SET sequence_group = ? WHERE id = ?", values: [items.count - i,item.id!])
                }
                success = true
            } catch {
                rollback.pointee = true
                success = false
            }
        }
        
        return success
    }
    
    func updateItemsSequenceInSpace(items:[Item]) -> Bool {
        var success = false
        queue.inTransaction { (db, rollback) in
            do {
                for i in 0..<items.count{
                    let item = items[i]
                    try db.executeUpdate("UPDATE tb_item SET sequence_space = ? WHERE id = ?", values: [items.count - i,item.id!])
                }
                success = true
            } catch {
                rollback.pointee = true
                success = false
            }
        }
        
        return success
    }
    
    
    
    
}
