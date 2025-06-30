//
// Copyright 2022-2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Compound
import SentrySwiftUI
import SwiftUI

struct HomeScreen: View {
    @ObservedObject var context: HomeScreenViewModel.Context
    
    @State private var scrollViewAdapter = ScrollViewAdapter()
    
    @State var selectedIndex = 1
    
    var body: some View {
        VStack {
            switch selectedIndex {
            case 1:
                HomeScreenContent(context: context, scrollViewAdapter: scrollViewAdapter)
                    .alert(item: $context.alertInfo)
                    .alert(item: $context.leaveRoomAlertItem,
                           actions: leaveRoomAlertActions,
                           message: leaveRoomAlertMessage)
//                    .toolbar(.hidden)
//                    .navigationTitle(L10n.screenRoomlistMainSpaceTitle)
//                    .toolbar { toolbar }
//                    .background(Color.compound.bgCanvasDefault.ignoresSafeArea())
                    .track(screen: .Home)
                    .bloom(context: context,
                           scrollViewAdapter: scrollViewAdapter,
                           isNewBloomEnabled: context.viewState.isNewBloomEnabled)
                    .sentryTrace("\(Self.self)")
            default: Color.white.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            HStack(alignment: .center) {
                tabButton(title: "Home", icon: "ic_tab_home", index: 0)
                tabButton(title: "Chat", icon: "ic_tab_chat", index: 1)

                Button {
                    withAnimation {
                        selectedIndex = 2
                    }
                } label: {
                    VStack {
                        Image("ic_tab_add")
                    }
                    .frame(maxWidth: .infinity)
                }
                
                tabButton(title: "Payment", icon: "ic_tab_payment", index: 3)
                tabButton(title: "Call", icon: "ic_tab_call", index: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.top, 10)
            .background(Color.white)
            .shadow(color: Color.theme(.black).opacity(0.1), radius: 20, x: 0, y: -4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Private
    private func tabButton(title: String, icon: String, index: Int) -> some View {
        Button {
            withAnimation {
                selectedIndex = index
            }
        } label: {
            VStack(spacing: 4) {
                Spacer()
                Image(icon)
                Text(title)
                    .font(.Roboto(.bold, size: 12))
                    .foregroundColor(Color.theme(.gray_737373))
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
        
//    @ToolbarContentBuilder
//    private var toolbar: some ToolbarContent {
//        ToolbarItem(placement: .navigationBarLeading) {
//            Button {
//                context.send(viewAction: .showSettings)
//            } label: {
//                LoadableAvatarImage(url: context.viewState.userAvatarURL,
//                                    name: context.viewState.userDisplayName,
//                                    contentID: context.viewState.userID,
//                                    avatarSize: .user(on: .home),
//                                    mediaProvider: context.mediaProvider)
//                    .accessibilityIdentifier(A11yIdentifiers.homeScreen.userAvatar)
//                    .overlayBadge(10, isBadged: context.viewState.requiresExtraAccountSetup)
//                    .compositingGroup()
//            }
//            .accessibilityLabel(L10n.commonSettings)
//        }
//        
//        ToolbarItem(placement: .primaryAction) {
//            newRoomButton
//        }
//    }
    
    @ViewBuilder
    private var newRoomButton: some View {
        switch context.viewState.roomListMode {
        case .empty, .rooms:
            Button {
                context.send(viewAction: .startChat)
            } label: {
                CompoundIcon(\.plus)
            }
            .buttonStyle(.compound(.super, size: .toolbarIcon))
            .accessibilityLabel(L10n.actionStartChat)
            .accessibilityIdentifier(A11yIdentifiers.homeScreen.startChat)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func leaveRoomAlertActions(_ item: LeaveRoomAlertItem) -> some View {
        Button(item.cancelTitle, role: .cancel) { }
        Button(item.confirmationTitle, role: .destructive) {
            context.send(viewAction: .confirmLeaveRoom(roomIdentifier: item.roomID))
        }
    }
    
    private func leaveRoomAlertMessage(_ item: LeaveRoomAlertItem) -> some View {
        Text(item.subtitle)
    }
}

// MARK: - Previews

struct HomeScreen_Previews: PreviewProvider, TestablePreview {
    static let loadingViewModel = viewModel(.skeletons)
    static let emptyViewModel = viewModel(.empty)
    static let loadedViewModel = viewModel(.rooms)
    
    static var previews: some View {
        NavigationStack {
            HomeScreen(context: loadingViewModel.context)
        }
        .snapshotPreferences(expect: loadedViewModel.context.$viewState.map { state in
            state.roomListMode == .skeletons
        })
        .previewDisplayName("Loading")
        
        NavigationStack {
            HomeScreen(context: emptyViewModel.context)
        }
        .snapshotPreferences(expect: emptyViewModel.context.$viewState.map { state in
            state.roomListMode == .empty
        })
        .previewDisplayName("Empty")
        
        NavigationStack {
            HomeScreen(context: loadedViewModel.context)
        }
        .snapshotPreferences(expect: loadedViewModel.context.$viewState.map { state in
            state.roomListMode == .rooms
        })
        .previewDisplayName("Loaded")
    }
    
    static func viewModel(_ mode: HomeScreenRoomListMode) -> HomeScreenViewModel {
        let userID = "@alice:example.com"
        
        let roomSummaryProviderState: RoomSummaryProviderMockConfigurationState = switch mode {
        case .skeletons:
            .loading
        case .empty:
            .loaded([])
        case .rooms:
            .loaded(.mockRooms)
        }
        
        let clientProxy = ClientProxyMock(.init(userID: userID,
                                                roomSummaryProvider: RoomSummaryProviderMock(.init(state: roomSummaryProviderState))))
        
        let userSession = UserSessionMock(.init(clientProxy: clientProxy))
        
        return HomeScreenViewModel(userSession: userSession,
                                   selectedRoomPublisher: CurrentValueSubject<String?, Never>(nil).asCurrentValuePublisher(),
                                   appSettings: ServiceLocator.shared.settings,
                                   analyticsService: ServiceLocator.shared.analytics,
                                   notificationManager: NotificationManagerMock(),
                                   userIndicatorController: ServiceLocator.shared.userIndicatorController)
    }
}
