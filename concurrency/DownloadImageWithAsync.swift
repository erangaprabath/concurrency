//
//  DownloadImageWithAsync.swift
//  concurrency
//
//  Created by Eranga prabath on 2023-11-22.
//

import SwiftUI
import Combine


class downloadImageWithAsyncImageLoder:ObservableObject{
    let  url  = URL(string: "https://picsum.photos/200")!
    var isError:Bool = false
    
    func handelResponse(data:Data?,response:URLResponse?)-> UIImage?{
        
        guard let data = data,
              let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else{
            return nil
        }
        return image
    }
    
    func dowloadImageWithEscaping(completionHandeler:@escaping(_ image :UIImage?,_ error:Error? ) -> ()){
        URLSession.shared.dataTask(with: url) { [ weak self ] data, response, error in
            let image = self?.handelResponse(data: data, response: response)
            completionHandeler(image,error )
        }
        .resume()
    }
    func downloadWithCombine() -> AnyPublisher<UIImage?,Error>{
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handelResponse)
            .mapError({$0})
            .eraseToAnyPublisher()
    }
    func downloadWithAsync()async throws -> UIImage?{
        do{
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handelResponse(data: data, response: response)
            
        }catch {
            isError.toggle()
            throw error
            
        }
    }
}

class DownloadImageWithAsyncViewModel:ObservableObject{
    @Published var image:UIImage? = nil
    let imageLoder = downloadImageWithAsyncImageLoder()
    var cancellable = Set<AnyCancellable>()
    var errorPopUp: Bool = false
    
    func fetchImage() async{
        /*
         imageLoder.dowloadImageWithEscaping { [ weak self ]image, error in
         if let image = image{
         DispatchQueue.main.async {
         self?.image = image
         }
         
         }
         }
         */
        
        /*
         imageLoder.downloadWithCombine()
         .receive(on: DispatchQueue.main)
         .sink { _ in
         
         } receiveValue: { [weak self] image in
         DispatchQueue.main.async {
         self?.image = image
         }
         }
         .store(in: &cancellable)
         */
        let image = try? await imageLoder.downloadWithAsync()
        let errorPopUp = imageLoder.isError
        await MainActor.run {
            self.errorPopUp = errorPopUp
            self.image = image
        }
        
    }
}

struct DownloadImageWithAsync: View {
    @StateObject private var viewModel = DownloadImageWithAsyncViewModel()
    var body: some View {
        ZStack{
            if viewModel.errorPopUp == true{
                Rectangle()
                    .frame(width: 100,height: 100)
            }else{
                if let image = viewModel.image{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250,height: 250)
                }
            }
            
        } .onAppear(){
            Task{
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImageWithAsync()
}
