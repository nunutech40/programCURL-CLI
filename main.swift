import Foundation

func runCLI() {

    print("---------------------------------------")
    print("🌐 Swift API Network CLI (Interactive)")
    print("---------------------------------------")

    // 1. Minta Input URL
    print("Masukkan URL lengkap (cth: https://jsonplaceholder.typicode.com/posts/1):")
    guard let urlString = readLine(), !urlString.isEmpty else {
        print("URL tidak boleh kosong.")
        exit(1)
    }

    // 2. Minta Input Metode
    print("\nPilih Metode (G untuk GET, P untuk POST):")
    guard let methodArg = readLine()?.lowercased(), !methodArg.isEmpty else {
        print("Metode tidak boleh kosong.")
        exit(1)
    }

    // 3. Validasi URL
    guard let _ = URL(string: urlString) else {
        print("URL '\(urlString)' tidak valid.")
        exit(1)
    }

    // validasi Method
    var method: HTTPMEthod
    switch methodArg {
    case "g":
        method = .get
    case "p":
        method = .post
    default:
        print("method \(methodArg) tidak valid, gunakan 'g' atau 'p'")
        exit(1)
    }

    // Melakukan request ke API
    let apiNetwork = APINetwork.shared
    apiNetwork.request(urlString: urlString, method: method) { data, response, error in
   
        if let error = error {
            print("Error: \(error.localizedDescription)")
            exit(1)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response type")
            exit(1)
        }

       // Menjadi:
        guard httpResponse.statusCode == 200 else {
            // Jika status code BUKAN 200 atau 201, baru anggap sebagai error.
            print("\n❌ HTTP Error: \(httpResponse.statusCode)") 
            if let data = data, let content = String(data: data, encoding: .utf8) {
                print("Response Body (Error):\n\(content)")
            }
            exit(1)
        }
        if let data = data, let content = String(data: data, encoding: .utf8) {
           do {
            // 1. Coba konversi data mentah menjadi object JSON (Dictionary atau Array)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

            // 2. Coba konversi object JSON menjadi data JSON yang terformat (pretty-printed)
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])

            if let prettyString = String(data: prettyData, encoding: .utf8) {
                print("\n✅ Response Data (Status \(httpResponse.statusCode)) - Prettified:\n")
                print(prettyString)
            } else {
                print("\n⚠️ Respon berhasil, namun gagal mengonversi data cantik menjadi string.")
            }
           } catch {
            // Jika data bukan JSON yang valid, tampilkan string mentahnya
            print("\n⚠️ Respon bukan JSON. Menampilkan string mentah:")
            let rawContent = String(data: data, encoding: .utf8) ?? "[Binary Data]"
            print(rawContent)
           }
        } else {
           print("\n✅ No data received (Status \(httpResponse.statusCode))")
        }
        exit(0)
    }

    // 5. Menjaga Program CLI Tetap Hidup
    RunLoop.main.run()
}

runCLI()