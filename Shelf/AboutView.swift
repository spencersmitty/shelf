import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 8) {
            #if os(macOS)
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
                .cornerRadius(16)
            #else
            Image(systemName: "app.fill")
                .resizable()
                .frame(width: 96, height: 96)
                .cornerRadius(16)
            #endif

            Text("Shelf")
                .font(.title)
                .bold()

            Text("Version 1.0")
                .font(.subheadline)

            Text("© 2025 smitty")
                .font(.footnote)

            Text("All Rights Reserved.")
                .font(.footnote)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .frame(idealWidth: 360)
        .multilineTextAlignment(.center)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
