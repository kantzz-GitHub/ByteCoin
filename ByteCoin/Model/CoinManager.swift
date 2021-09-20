import Foundation
protocol CoinManagerDelegate{
    func didUpdateCoin(lastPrice: Double)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    let apiKey = "?apikey=6C09F803-E300-4792-A591-4D27E09E41AD"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String){
        let myURLString = baseURL + "\(currency)" + apiKey
        performRequest(with: myURLString)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data{
                    
//                    let dataString = String(data: safeData, encoding: .utf8)
                    
                    if let rate = parseJSON(safeData){
                        delegate?.didUpdateCoin(lastPrice: rate)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
