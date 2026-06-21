import Foundation

protocol CitizenRepository {
    func fetchMe() async throws -> Citizen
    func updateDistricts(home: District?, livingIn: District?) async throws -> Citizen
}

final class HTTPCitizenRepository: CitizenRepository {
    private let client: APIClient

    init(client: APIClient = ServiceLocator.shared.client) {
        self.client = client
    }

    func fetchMe() async throws -> Citizen {
        let dto = try await client.send(.get, "profile/me", decode: CitizenMeDTO.self)
        return dto.toModel()
    }

    func updateDistricts(home: District?, livingIn: District?) async throws -> Citizen {
        var query: [URLQueryItem] = []
        if let home { query.append(URLQueryItem(name: "homeDistrictId", value: home.id)) }
        if let livingIn { query.append(URLQueryItem(name: "livingInDistrictId", value: livingIn.id)) }
        try await client.send(.patch, "verification/districts", query: query, body: nil)
        return try await fetchMe()
    }
}

final class MockCitizenRepository: CitizenRepository {
    func fetchMe() async throws -> Citizen {
        try await Task.sleep(nanoseconds: 200_000_000)
        return MockData.currentCitizen
    }

    func updateDistricts(home: District?, livingIn: District?) async throws -> Citizen {
        try await Task.sleep(nanoseconds: 200_000_000)
        var me = MockData.currentCitizen
        me.homeDistrict = home
        me.livingInDistrict = livingIn
        return me
    }
}
