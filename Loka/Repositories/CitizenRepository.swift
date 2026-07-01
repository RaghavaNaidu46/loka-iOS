import Foundation

protocol CitizenRepository {
    func fetchMe() async throws -> Citizen
    func updateDistricts(home: District?, livingIn: District?) async throws -> Citizen
}

final class HTTPCitizenRepository: CitizenRepository {
    private let client: any APIClient

    init(client: any APIClient = ServiceLocator.shared.client) {
        self.client = client
    }

    func fetchMe() async throws -> Citizen {
        let dto = try await client.send(Endpoints.me(), decode: CitizenMeDTO.self)
        return dto.toModel()
    }

    func updateDistricts(home: District?, livingIn: District?) async throws -> Citizen {
        try await client.send(Endpoints.updateDistricts(homeDistrictId: home?.id, livingInDistrictId: livingIn?.id))
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
