import Kitura
import KituraContracts

func initializeApi_Routes(app: App) {
  // Handlers for codable routes are declared below:
  //
  func getOne__api_fortune__handler(id: String, completion: (Fortune?, RequestError?) -> Void ) -> Void {
    let fortune = Fortune(fortune: "Mock fortunes are fake news.")
    completion(fortune, nil)
  }
  
  // Codable routes are declared below:
  //
  app.router.get("/api/fortune/", handler: getOne__api_fortune__handler)
}

