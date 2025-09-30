//
//  init_notes.swift
//  pos
//
//  Created by Khaled on 8/7/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
typealias init_notes = combo_vc
extension init_notes
{
    
    func load_notes()
    {
            self.get_notes()
            self.get_note_selected()
    }
    
    
    func get_notes()
    {
        var list_notes:[pos_product_notes_class] =  pos_product_notes_class.getAll(delet: false)
        if list_notes.count > 0
        {
            self.list_notes.removeAll()
            
            self.filter_items(arr: list_notes )
        }
        
        let index = list_collection_keys.count + 1

        let sec = section_view.init(index_row:index, title: "Notes".arabic("ملاحظات"), type: .note)

                self.list_collection_keys.removeAll(where: {$0.type == .note})
                self.list_collection_keys.append(contentsOf: [sec])
//                self.list_collection_keys.append(sec)
//        for key  in list_notes
//        {
//            let sec = section_view.init(index_row:index, title: key.name, type: .variant)
//            index += 1
//            list_collection_keys.append(sec)
//
//
//        }
        
        
    }
    
    func filter_items(arr:[pos_product_notes_class] )
    {
        
        if  product_combo?.product?.pos_categ_id != 0
        {
            let pos_categ_id = product_combo!.product?.pos_categ_id ?? 0
            for item in arr
            {
                let pos_category_ids = item.get_pos_category_ids() // item["pos_category_ids"] as? [Int]
                let index =  pos_category_ids.firstIndex(of: pos_categ_id)
                if index != nil
                {
                    self.list_notes.append(item)
                    
                }
            }
        }
        
        
        
        
    }
    
    
    func add_note(note:pos_product_notes_class,plus:Bool)
    {
      var get_note = list_notes_selected[note.id]
               if get_note == nil
               {
                   
                 get_note = note
                  get_note!.qty = 1
               }
               else
               {
                if plus
                {
                    get_note!.qty += 1

                }
                else
                {
                    get_note!.qty -= 1

                }

               }
        
        if get_note?.qty == 0
        {
            list_notes_selected.removeValue(forKey: note.id)
        }
        else
        {
            list_notes_selected[note.id] = get_note

        }
         

               regenrateText()
        
        collection.reloadData()

        done(removeFromSuperview: false)

    }
    
    func add_note(indexPath: IndexPath)
    {
         let note = list_notes[indexPath.row]
 
           add_note(note: note,plus: true)
        
    }
    
    func get_note_selected()
    {
       
        let txt = product_combo?.note ?? ""
        let split = txt.split(separator: "\n")
        for note in split
        {
            let line_temp = note.replacingOccurrences(of: "◉ ", with: "")
            let line_note = line_temp.split(separator: "-")
            if line_note.count >= 2
            {
                let qty:String = String(line_note[0])
                if let qtyInt = qty.toInt() {
                let txt_note = line_temp.replacingOccurrences(of: "\(qtyInt)-", with: "")
                
                let note  = self.list_notes.first(where: {$0.display_name == txt_note})
                if note != nil
                {
                    note?.qty = qtyInt
                            list_notes_selected[note!.id] = note
                }
                }
                
            }
        }
    }
    
    func clear_notes()
       {
        list_notes_selected.removeAll()
        product_combo?.note = ""

            
            collection.reloadData()
        
        done(removeFromSuperview: false)

       }
    
    
    func regenrateText()
    {
        var txt = ""
        
        for item in list_notes_selected
        {
            if txt.isEmpty
            {
                txt = "◉ \(item.value.qty)-\(item.value.display_name)"
            }
            else
            {
                txt = "\(txt)\n◉ \(item.value.qty)-\(item.value.display_name)"
            }
        }
        
        var written_not = ""
        let lines: [String] = product_combo?.note!.components(separatedBy: "\n") ?? []
        for line in lines
        {
            if !line.starts(with: "◉ ")
            {
                written_not = written_not + "\n" + line
            }
        }

        txt = txt + written_not
        // Remove trailing comma and whitespaces
        txt = txt.trimmingCharacters(in: .whitespacesAndNewlines)
        txt = txt.replacingOccurrences(of: ",\\s*$", with: "", options: .regularExpression)
        product_combo?.note = txt
    }
    
  

    func textViewDidEndEditing(_ textView: UITextView) {
        product_combo?.note = textView.text
        
        done(removeFromSuperview: false)

     }
    
    
}
