//
//  Carte.swift
//  NSXMLparser_tutorial
//
//  Created by Gabriel Amyot on 2015-11-10.
//  Copyright © 2015 tutorials. All rights reserved.
//

import Foundation

///Carte de jeux
class Carte {
    
    // Nom sous lequel la carte est erregistre
    var nomFichier : String
    //Arbre contenant les objets de la table de jeux
    var arbre = Arbre()
    //Proprietes de la table de jeux
    var proprietes = Proprietes()
    
    ///Constructeur
    init(nom : String){
        nomFichier = nom
    }
    
    ///Getters
    func getNom() -> String{
        return nomFichier
    }
    
    func getArbre() -> Arbre{
        return arbre
    }
    
    func getProprietes() -> Proprietes{
        return proprietes
    }
    
    ///verifier si la care de jeux poseder au moin : generateur de bille, trou,table
    func verifierValidite() -> Bool{
        var trouPresent = false
        var generateurPresent = false
        var ressortPresent = false
        let tablePresente = self.arbre.table != nil
        
        for objet in self.arbre.autresObjets{
            switch objet.type!{
                case "trou":
                    trouPresent = true
                case "generateurDeBilles":
                    generateurPresent = true
                case "ressort":
                    ressortPresent = true
                default:
                    //je dois m metre qq chose ici, mais je ne veux pas.
                    print("")
            }
            
        }
        
        if trouPresent && generateurPresent && ressortPresent && tablePresente{
            return true
        }
        return false
    }
    
    ///Imprime la carte en format xml
    func toXmlString() -> NSString!{
        if !verifierValidite(){
            print("Carte invalide, elle ne peux etre sauvegarde ")
            return nil
        }

        
        let sauvegardeCarte = AEXMLDocument()
        let jeuxXml = sauvegardeCarte.addChild(name: "jeux")
        let arbreXml = jeuxXml.addChild(name: "arbre")
        let proprieteXml = jeuxXml.addChild(name: "propriete")
        
        
        ///table
        let attributsTable = ["positionx": "\((self.arbre.table?.positionX)!)" ,"positiony": "\((self.arbre.table?.positionY)!)"]
        arbreXml.addChild(name:"table",attributes: attributsTable)
        
        ///portail
        for objet in self.arbre.portail{
            let attributs = ["positionx" : "\(objet.positionX!)", "positiony" : "\(objet.positionY!)", "echelle" : "\(objet.echelle!)", "angleRotation" : "\(objet.angleRotation!)"]
            arbreXml.addChild(name:"\(objet.type!)",attributes: attributs)
        }
        
        ///mur
        for objet in self.arbre.mur{
            let attributs = ["positionx" : "\(objet.positionX!)", "positiony" : "\(objet.positionY!)", "largeurMur" : "\(objet.largeurMur!)", "angleRotation" : "\(objet.angleRotation!)"]
            arbreXml.addChild(name:"\(objet.type!)",attributes: attributs)
        }
        
        ///AutresObjets
        for objet in self.arbre.autresObjets{
            let attributs = ["positionx" : "\(objet.positionX!)", "positiony" : "\(objet.positionY!)", "echelle" : "\(objet.echelle!)", "angleRotation" : "\(objet.angleRotation!)"]
            arbreXml.addChild(name:"\(objet.type!)",attributes: attributs)
        }
        
        ///proprites
        proprieteXml.addChild(name: "ButoirCirculair", attributes: ["point":"\((self.proprietes.pointageButoirCirculaire)!)"])
        proprieteXml.addChild(name: "ButoirTriangulair", attributes: ["point":"\((self.proprietes.pointageButoirTriangulaire)!)"])
        proprieteXml.addChild(name: "Cible", attributes: ["point":"\((self.proprietes.pointageCible)!)"])
        proprieteXml.addChild(name: "passezNiveau", attributes: ["point":"\((self.proprietes.pointagePourPasserNiveau)!)"])
        proprieteXml.addChild(name: "Billegratuite", attributes: ["point":"\((self.proprietes.pointagePourBillegratuite)!)"])
        proprieteXml.addChild(name: "NiveauDiffulte", attributes: ["point":"\((self.proprietes.niveauDiffulte)!)"])
        
        return sauvegardeCarte.xmlString
    }
}

///Proprietes de la carte
class Proprietes{
    var pointageButoirCirculaire : Int?
    var pointageButoirTriangulaire : Int?
    var pointageCible : Int?
    var pointagePourPasserNiveau : Int?
    var pointagePourBillegratuite : Int?
    var niveauDiffulte : Int?

    
    ///Setters pour les proprietes
    func setPointageButoirCirculaire(points : Int){
        pointageButoirCirculaire = points
    }
    func setPointageButoirTriangulaire(points : Int){
        pointageButoirTriangulaire = points
    }
    func setPointageCible(points : Int){
        pointageCible = points
    }
    func setPointagePourPasserNiveau(points : Int){
        pointagePourPasserNiveau = points
    }
    func setPointagePourBillegratuite(points : Int){
        pointagePourBillegratuite = points
    }
    func setDifficulte(difficulte : Int){
        niveauDiffulte = difficulte
    }

}

///Arbre contenant tout les objets du jeux
class Arbre {
    internal var table : ObjetDeScene?
    var autresObjets = Array<AutreObjetDeScene>()
    var mur = Array<Mur>()
    var portail = Array<AutreObjetDeScene>()

    
    ///Setter pour table
    func ajouterTable(posX : Int, posY : Int){
        table =  ObjetDeScene(type:"table", x:posX, y:posY)
    }
    
    ///Setter pour le mur
    func ajouterMur(posX : Int, posY : Int, largeurMur : Int, angleRotation : Int){
        mur.append(Mur(typeObj:"mur", x:posX, y:posY, largeur:largeurMur, angle: angleRotation))
    }
    
    ///Setter pour portail
    func ajouterPortail(posX : Int, posY : Int, echellePortail : Int, angleRotation : Int){
        portail.append(AutreObjetDeScene(typeObj:"portail", x:posX, y:posY, echelleObj:echellePortail, angle: angleRotation))
    }
    
    func ajouterAutreObjet(nom:String, posX : Int, posY : Int, echelleObjet : Int, angleRotation : Int){
        autresObjets.append(AutreObjetDeScene(typeObj: nom, x: posX, y: posY, echelleObj: echelleObjet, angle: angleRotation))
    }
}



///classe de base pour un objet de scene
/// obs: la "table" est le seul objet instancié directement a partir de AutreObjetDeScene
class ObjetDeScene{
    init (type : String, x : Int, y : Int){
        self.type = type
        self.positionX = x
        self.positionY = y
    }
    
    var type : String?
    var positionX  : Int?
    var positionY  : Int?
}

///Spécification de ObjetDeScene pour un mur
class Mur : ObjetDeScene{
    init(typeObj : String, x : Int, y : Int, largeur: Int, angle: Int){
        
        super.init(type: typeObj,x: x,y: y)
        largeurMur = largeur
        angleRotation = angle
    }
    
    var largeurMur :Int?
    var angleRotation :Int?
    
}




///Spécification de ObjetDeScene pour tout les autres objets ObjetDeScene
class AutreObjetDeScene : ObjetDeScene{
    init(typeObj : String, x : Int, y : Int, echelleObj: Int, angle: Int){
      
        super.init(type: typeObj,x: x,y: y)
        echelle = echelleObj
        angleRotation = angle
    }
    
    var echelle : Int?
    var angleRotation : Int?
}

