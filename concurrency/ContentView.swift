//
//  ContentView.swift
//  concurrency
//
//  Created by Eranga prabath on 2023-11-22.
//

import SwiftUI

class doTryThrowsManager{
    
    let isActive:Bool = true
    
    func getTitel() -> (title:String?,error:Error?) {
        if isActive{
            return ("NEW TEXT!!",nil)
        }else{
            return (nil,URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String,Error>{
        if isActive{
            return .success("New Title")
        }else{
            return .failure(URLError(.badURL))
        }
        
        
    }
    
    func getTitle3() throws -> String{
        if isActive{
            return "New TEXT !!!"
        }else{
            throw URLError(.badURL)
        }
    }
    
    func getTitle4() throws -> String{
        if isActive{
            return "FINAL TEXT !!!"
        }else{
            throw URLError(.badURL)
        }
    }
}


class doCatchTryThrows:ObservableObject{
    
    @Published var text:String = "Starting text.."
    let manager = doTryThrowsManager()
    
    func fetchTitel(){
        /*
         let returnValue = manager.getTitel()
         if let newTitle = returnValue.title{
         self.text = newTitle
         }else if let error = returnValue.error{
         self.text = error.localizedDescription
         }*/
        /*
        let result = manager.getTitle2()
        switch result {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let failure):
            self.text = failure.localizedDescription
        }
         */
        do{
            let newTitle = try? manager.getTitle3()
            if let thisTitle = newTitle{
                self.text = thisTitle
            }
            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
        }catch let error{
            self.text = error.localizedDescription
        }
        
    }
    
}



struct ContentView: View {
    @StateObject private var viewModel = doCatchTryThrows()
    var body: some View {
        VStack {
            Text(viewModel.text)
                .frame(width: 300,height: 300)
                .background(Color.blue)
                .onTapGesture {
                    viewModel.fetchTitel()
             
                }
        }
    }
}

#Preview {
    ContentView()
}
