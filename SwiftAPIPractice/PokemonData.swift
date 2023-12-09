//
//  PokemonView.swift
//  SwiftAPIPractice
//
//  Created by 芥川浩平 on 2023/12/09.
//

import Foundation

struct Pokemon: Codable {
    let id: Int
    let name: String
    let sprites: Sprites

    struct Sprites: Codable {
        let other: Other

        struct Other: Codable {
            let officialArtwork: OfficialArtwork

            enum CodingKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
            }

            struct OfficialArtwork: Codable {
                let frontDefault: String

                enum CodingKeys: String, CodingKey {
                    case frontDefault = "front_default"
                }
            }
        }
    }
}


@MainActor
final class PokemonAPI: ObservableObject {
    @Published var pokemons: [Pokemon] = []

    func fetchall() async {
        await (1...151).asyncForEach { [self] id in
            await self.fetchData(id: id)
        }
    }
    func fetchData(id: Int) async {

        guard let req_url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)/") else {
            return
        }

        do {
            let (data , _) = try await URLSession.shared.data(from: req_url)
            let decoder = JSONDecoder()
            let pokemon = try decoder.decode(Pokemon.self, from: data)
            pokemons.append(pokemon)
        } catch {
            print("エラー発生")
        }
    }
}

//以下、1から151番目まで順番に並べるために追記

public extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }

    func concurrentMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T] {
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }

        return try await tasks.asyncMap { task in
            try await task.value
        }
    }
}

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }

    func concurrentForEach(
        _ operation: @escaping (Element) async -> Void
    ) async {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
        }
    }
}
