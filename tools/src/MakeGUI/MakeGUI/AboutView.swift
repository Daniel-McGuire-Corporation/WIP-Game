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
            
            Text("Alpha software may do fun things, including: (but not limited to)")
                .font(.headline)
                .padding(.top, 20)
            
            Text("1. Crashing. (Common)")
            Text("2. Not opening (Unlikely)")
            Text("2. Computer Explosion (ULTRA-RARE)")
            
            Text("Remember to REPORT ISSUES!")
                .font(.headline)
                .padding(.top, 5)
            Spacer()
            Text("Part of UNTITLEDGAME by DMC")
                .padding(.top, 25)
            Text("© 2024 Daniel McGuire Corporation")
                
        }
    }
}
#Preview {
    AboutView()
        .frame(width: 450, height: 325)
}
