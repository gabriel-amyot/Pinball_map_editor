//
//  SocketSession.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-11-30.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import Foundation


class SocketSession : NSObject, SocketIODelegate{

    
    var socket : SocketIO!
    var utilisateur = ""
    //var motDePasse = ""
    var connected = false
    var authenticate = false
    var erreur = false
    var typeErreur = ""
    
    //views
    var chat: ChatViewController!
    
    
    init(host: String, port:Int){
        super.init()
        socket = SocketIO(delegate:  self)
        //socket.connectToHost("localhost", onPort: 8000)
        socket.connectToHost("\(host)", onPort: port)
    }
    
    ///Connection au serveur
    func debuterSession(nomUtilisateur:String, motDePasse:String) {
        self.utilisateur = nomUtilisateur
      //  self.motDePasse = motDePasse
        
        //attendre 1.0 secondes avant de lancer l'authentification
        let seconds = 1.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            if self.connected{
                self.socket.sendEvent("authentification", withData: "\(nomUtilisateur)#\(motDePasse)")
            }
        })
    }
    
    ///socketIO
    ///message delegate
    func socketIO(socket: SocketIO, didReceiveMessage packet: SocketIOPacket) {
        //NSLog("didReceiveMessage >>> data: %@", packet.data)
        print("---------this is a message ! : \(packet.data)")
       
    }
    
    ///socketIO
    ///handle la connection delegate
    func socketIODidConnect(socket: SocketIO) {
        connected = true
        print("socketIODidConnect!!!!!!!!!!!!!")
        
    }
    /*
    ///SocketIO
    //Handle disconection
    override func socketIODidDisconnect(socket: SocketIO, disconnectedWithError error: NSErrorPointer) {
            print("dicon
                ected")
    }
    */
    ///socketIO
    ///event delegate
    func socketIO(socket: SocketIO, didReceiveEvent packet: SocketIOPacket) {
        let dict = convertStringToDictionary(packet.data)
        let event = dict!["name"]! as! String
        let args  = dict!["args"]! as! [String]

        switch(event){
            case "reponse connection":
                switch (args[0]){
                    case "true#\(utilisateur)":
                        authenticate = true
                        erreur = false
                        print("authenticate!!!!!!!!!!!!!!")
                    case "false#Mot de pass invalide":
                        erreur = true
                        typeErreur = "Mot de pass invalide"
                        print(typeErreur)
                    //message envoyer quand le nom d'utilisateur est incorect ou que le client est deja connecte au server
                    case "false#Nom d'utilisateur invalide":
                        erreur = true
                        typeErreur = "Nom d'utilisateur invalide"
                        print(typeErreur)
                        self.disconnect()
                    
                    default:
                        print("reponse connection not handle :\(args[0])")
                }
            case "userDisconnected":
                authenticate = false
                print("\(args[0]) disconnected!!!!!!!!!!!!!!")
            
            
            case  "error":
                print("Erreur avec socket.io: arguments: \(args)")
           
            //gestidu chat
            case "txt":
                print("General chat message: \(args[0])")
            chat.updateChatView(args[0])
            
            //case "roomChatReceive":
                //print("roomChatReceive message recu")
            
            case "message":
                print("Message: \(args)")
            
            
            
            case "reponse register":
                if args[0] == "true#Le compte a été ajouté avec succès"{
                    //confirmerInscription()
                }else if args[0] == "false#Nom d'utilisateur deja present, veuillez voisir un autre nom d'utilisateur"{
                    
                }
            
            default:
                print("--Evenement inconu: \(event)")
                print("--Arguments: \(args)")
            
        
        }
        
        
    }
    
    //SocketIO
    //envoyerMessage au chat
    func envoyerMessageChat(message:String){
        self.socket.sendEvent("general message", withData: message)
        
       // self.socket.sendEvent("roomChatSend", withData: message)
        
    }
    
    
    ///Cette méthode associe le view controller du chat a la variable chat du socket
    ///Le but de cette methode est davoir acces au ChatViewController et d'actualiser la valeur de messages quand un npouveau message est recu
    ///Cette approche nest pas optimal ( le modele qui modifie la vue) (this is disgusting holy shit!)
    func connecterChatView(chat:ChatViewController){
        self.chat = chat
    
    }
    
    func deconnecterChatView(){
        self.chat = nil
    }
    
    
    
    //Convertis un fichier jSon en dictionaire
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Erreur: Conversion jSon -> string ")
            }
        }
        return nil
    }
    
    ///Quite le chat
    func disconnect(){
        self.socket.sendEvent("exit", withData: "\(self.utilisateur)")
        connected = false
        authenticate = false
    }
    
    
 
    func isAuthenticate() -> Bool  {
        return self.authenticate
    }
    
    func connectionAccepte(message : String){
        self.connected = true
        
    }
}
