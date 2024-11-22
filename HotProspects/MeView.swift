//
//  MeView.swift
//  HotProspects
//
//  Created by Reza Enayati on 9/30/24.
//
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    
    @AppStorage("name") private var name = "Anonymous"
    @AppStorage("email") private var email = "Your Email"
    
    @State private var qrCode = UIImage()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter Name", text: $name)
                    .font(.headline)
                TextField("Enter Email", text: $email)
                    .font(.headline)
                
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .contextMenu{
                        ShareLink(item: Image(uiImage: qrCode), preview: SharePreview("My QR Code", image: Image(uiImage: qrCode)))
                    }
                    
            }
            .navigationTitle("Your Code")
            .onAppear(perform: updateQR)
            .onChange(of: name, updateQR)
            .onChange(of: email, updateQR)
        }
    }
    
    func updateQR(){
        qrCode = genreateQRCode(from: "\(name)\n\(email)")
    }
    
    func genreateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let output = filter.outputImage {
            if let cgImage = context.createCGImage(output, from: output.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
        
    }
}

#Preview {
    MeView()
}
