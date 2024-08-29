import SwiftUI

struct AboutView: View {
    @AppStorage("showAboutWindow") private var showAboutWindow: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About MakeGUI")
                .font(.title)
                .padding(.bottom, 10)
            
            Text("Version 0.1.0.1 Alpha")
                .font(.subheadline)
            
            Spacer()
            
            Text("Alpha software may do fun things, including:")
                .font(.headline)
                .padding(.top, 20)
            
            Text("1. Crashing. (Common)")
            Text("2. Not opening (Unlikely)")
            Text("3. Other unpleasant things.")
            
            Spacer()
            
            Text("Remember to REPORT ISSUES!")
                .font(.headline)
                .padding(.top, 20)
            
            Text("Part of UNTITLEDGAME by DMC")
            Text("© 2024 Daniel McGuire Corporation")
                .padding(.top, 5)
        }
    }
}
#Preview {
    AboutView()
}
