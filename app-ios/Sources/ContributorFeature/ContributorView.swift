import ComposableArchitecture
import KMPClient
import SwiftUI
import Theme
import shared
import CommonComponents

public struct ContributorView: View {
    private enum ContributorTab: String, CaseIterable {
        case swift
        case kmpPresenter
        case fullKmp

        var title: String {
            switch self {
            case .swift:
                "SwiftUI"

            case .kmpPresenter:
                "KMP Presenter"

            case .fullKmp:
                "KMP Compose View"
            }
        }
    }

    @State private var selectedTab: ContributorTab? = .swift
    @Namespace var namespace
    @Bindable var store: StoreOf<ContributorReducer>

    public init(store: StoreOf<ContributorReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            tabBar

            TabView(selection: $selectedTab) {
                SwiftUIContributorView(store: store)
                    .tag(ContributorTab.swift)

                KmpPresenterContributorView()
                    .tag(ContributorTab.kmpPresenter)

                KmpContributorComposeViewControllerWrapper { urlString in
                    guard let url = URL(string: urlString) else {
                        return
                    }
                    store.send(.view(.contributorButtonTapped(url)))
                }
                .tag(ContributorTab.fullKmp)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(AssetColors.Surface.surface.swiftUIColor)
        .navigationTitle(String(localized: "Contributor", bundle: .module))
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $store.url, content: { url in
            SafariView(url: url.id)
                .ignoresSafeArea()
        })
    }
    
    @MainActor
    private var tabBar: some View {
        HStack {
            ForEach(ContributorTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    ZStack {
                        Text(tab.title)
                            .textStyle(.titleMedium)
                            .foregroundStyle(
                                selectedTab == tab ? AssetColors.Primary.primaryFixed.swiftUIColor : AssetColors.Surface.onSurface.swiftUIColor
                            )
                        VStack {
                            Spacer()
                            Group {
                                if selectedTab == tab {
                                    AssetColors.Primary.primaryFixed.swiftUIColor
                                        .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                                } else {
                                    Color.clear
                                }
                            }
                            .frame(height: 3)
                        }
                    }
                    .frame(height: 52, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .animation(.spring(), value: selectedTab)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    ContributorView(store: .init(initialState: .init(), reducer: { ContributorReducer() }))
}
