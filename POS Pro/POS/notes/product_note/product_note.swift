//
//  product_note.swift
//  pos
//
//  Created by khaled on 10/24/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

protocol product_note_delegate {
       func note_added()
}

class product_note: UIViewController,UITextViewDelegate {
    private let reuseIdentifier = "FlickrCell"

    @IBOutlet weak var collection: UICollectionView!

 
//    var note_geterated:String = ""
    
    var delegate:product_note_delegate?
    
    var order:pos_order_class?
    
    
     let con = SharedManager.shared.conAPI()

   var list_notes: [pos_product_notes_class] = []
//    public var selected_items: [Int:[String : Any]]! = [:]
    var list_notes_selected: [Int:pos_product_notes_class] = [:]


    
      override func viewDidDisappear(_ animated: Bool) {
          super.viewDidDisappear(animated)
       
        order = nil
      
        list_notes.removeAll()
        list_notes_selected.removeAll()
        
       }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         get_notes()
    }
    
    func get_note_selected()
       {
        let txt =  order?.note ?? ""
           let split = txt.split(separator: "\n")
           for note in split
           {
            let line_temp = note.replacingOccurrences(of: "> ", with: "")

               let line_note = line_temp.split(separator: "-")
               if line_note.count == 2
               {
                   let qty:String = String(line_note[0])
                let txt_note:String = String(line_note[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                   
                   let note  = self.list_notes.first(where: {$0.display_name == txt_note})
                   if note != nil
                   {
                    note?.qty = qty.toInt()!
                    list_notes_selected[note!.id] = note
                   }
          

               }
           }
       }
    
    func get_notes()
    {
        let list :[pos_product_notes_class] = pos_product_notes_class.getAll()
        self.list_notes.append(contentsOf: list)
   

       self.get_note_selected()
        
             self.collection.reloadData()
        
    }
    
    
   
 
   @IBAction func btnOk(_ sender: Any) {
    
 
//    order?.note = note_geterated
//
//    order?.save()
//    delegate?.note_added()
    
    self.view.removeFromSuperview()
    
//    self.dismiss(animated: true, completion: nil)
    
  }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.view.removeFromSuperview()

//        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_clear(_ sender: Any) {
        
       list_notes_selected.removeAll()
               order?.note = ""

        order?.save()
        delegate?.note_added()
                
       collection.reloadData()
    }
    
}
extension product_note:UICollectionViewDelegate,UICollectionViewDataSource {
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return list_notes.count
        
    }
    
    //3
    func collectionView(  _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath  ) -> UICollectionViewCell {
        let cell = collectionView  .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! product_noteViewCell
        //        cell.backgroundColor = .lightGray
        // Configure the cell
        
        let note = list_notes[indexPath.row]
  
        cell.parent_vc = self
        cell.note = note


        cell.updateCell()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
           
         if (kind == UICollectionView.elementKindSectionFooter)
           {

                 return footer_cell(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    
           }
           
           return UICollectionReusableView()
           
       }
       func footer_cell(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
       {
        let footer_View:product_note_footer_cell  =  (collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "product_note_footer_cell", for: indexPath) as! product_note_footer_cell)
           
           
        footer_View.isHidden = false
        footer_View.txt_notes.text = order?.note
        footer_View.txt_notes.delegate = self
           
           
        return footer_View
           
       }
       
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        add_note(indexPath: indexPath  )

 
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
//            note_geterated = textView.text
        order?.note = textView.text
        order?.save(write_date:false)
        delegate?.note_added()

//             done(removeFromSuperview: false)
        
       }
      
    
    func regenrateText()
    {
          var txt = ""
        
        for item in list_notes_selected
        {
            if txt.isEmpty
            {
                txt = "> \(item.value.qty)-\(item.value.display_name)"
            }
            else
            {
                txt = "\(txt)\n> \(item.value.qty)-\(item.value.display_name)"
            }
        }
        
        var written_not = ""
        let lines: [String] = order?.note.components(separatedBy: "\n") ?? []
        for line in lines
        {

            if !line.starts(with: "> ") && !line.isEmpty
            {
                 
                written_not = written_not + "\n" + line
            }
        }

   
        txt = txt + written_not
 
//     note_geterated = txt
        
      order?.note = txt
    }
    
    func add_note(indexPath: IndexPath)
       {
            let note = list_notes[indexPath.row]
    
              add_note(note: note,plus: true)
           
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
           
           order?.save(updated_session_status:.last_update_from_local)
        delegate?.note_added()

           collection.reloadData()
       }
    
}

