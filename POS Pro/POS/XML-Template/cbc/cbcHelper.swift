class CBCHelper {
    
    static func getTemplate(_ cbc:[CBC_TEMPLATE:String]?) -> String{
        
        return CBC_TEMPLATE.getTemplate(from:cbc ?? [:])
        
    }
    
}
