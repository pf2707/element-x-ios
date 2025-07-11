//
// Copyright 2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SentrySwiftUI
import SwiftUI

struct HomeScreenContent: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @ObservedObject var context: HomeScreenViewModel.Context
    let scrollViewAdapter: ScrollViewAdapter
    @FocusState var isFocused: Bool
    @State var showRoomAction: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("Chat")
                    .font(.Roboto(.semibold, size: 16))
                    .foregroundColor(Color.theme(.black_181718))
                Spacer()
                HStack {
                    Button {
                        context.send(viewAction: .startChat)
                    } label: {
                        Image("ic_create")
                    }
                    Button {
                        context.send(viewAction: .showSettings)
                    } label: {
                        Image("ic_setting")
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 110, alignment: .bottom)
            .background(Color.theme(.white))
            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
            .ignoresSafeArea()
            
            roomList                                        
                .sentryTrace("\(Self.self)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, -44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.theme(.gray_FAFAFA))
        .sheet(isPresented: $showRoomAction) {
            VStack(alignment: .center, spacing: 0) {
                Color.theme(.gray_DFE2EB)
                    .frame(width: 60, height: 4)
                    .cornerRadius(2)
                    .padding(.top, 12)
                
                // Mute/Unmute
                Button {
                    context.send(viewAction: .showSettings)
                } label: {
                    HStack(spacing: 12) {
                        Image("ic_action_mute")
                        Text("Mute")
                            .foregroundColor(Color.theme(.black_181718))
                            .font(.Roboto(.regular, size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 68)
                }
                Divider().frame(maxWidth: .infinity).frame(height: 1).background(Color.theme(.gray_F2F2F3))
                
                // Pin
                Button {
                    
                } label: {
                    HStack(spacing: 12) {
                        Image("ic_action_pin")
                        Text("Pin")
                            .foregroundColor(Color.theme(.black_181718))
                            .font(.Roboto(.regular, size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 68)
                }
                Divider().frame(maxWidth: .infinity).frame(height: 1).background(Color.theme(.gray_F2F2F3))
                
                // Create group
                Button {
                    
                } label: {
                    HStack(spacing: 12) {
                        Image("ic_action_create_group_with")
                        Text("Create group")
                            .foregroundColor(Color.theme(.black_181718))
                            .font(.Roboto(.regular, size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 68)
                }
                Divider().frame(maxWidth: .infinity).frame(height: 1).background(Color.theme(.gray_F2F2F3))
                
                // Archive/unarchive
                Button {
                    
                } label: {
                    HStack(spacing: 12) {
                        Image("ic_action_archive")
                        Text("Archive")
                            .foregroundColor(Color.theme(.black_181718))
                            .font(.Roboto(.regular, size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 68)
                }
                Divider().frame(maxWidth: .infinity).frame(height: 1).background(Color.theme(.gray_F2F2F3))
                
                // Delete
                Button {
                    
                } label: {
                    HStack(spacing: 12) {
                        Image("ic_action_delete")
                        Text("Delete")
                            .foregroundColor(Color.theme(.red_B91C1C))
                            .font(.Roboto(.regular, size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 68)
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.theme(.white))
            .presentationDetents([.height(360)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(16)
            .ignoresSafeArea()
        }

    }
    
    private var roomList: some View {
        GeometryReader { geometry in
            ScrollView {
                switch context.viewState.roomListMode {
                case .skeletons:
                    LazyVStack(spacing: 0) {
                        ForEach(context.viewState.visibleRooms) { room in
                            HomeScreenRoomCell(room: room, context: context, isSelected: false)
                                .redacted(reason: .placeholder)
                                .shimmer() // Putting this directly on the LazyVStack creates an accordion animation on iOS 16.
                        }
                    }
                    .disabled(true)
                case .empty:
                    HomeScreenEmptyStateLayout(minHeight: geometry.size.height) {
                        topSection
                        
                        HomeScreenEmptyStateView(context: context)
                            .layoutPriority(1)
                    }
                case .rooms:
                    LazyVStack(spacing: 0) {
                        Section {
                            if !context.viewState.shouldShowEmptyFilterState {
                                HomeScreenRoomList(context: context, showRoomAction: $showRoomAction)
                                    .background(Color.clear)
                            }
                        } header: {
                            topSection
                        }
                    }
                    .background(Color.theme(.white))
                    .cornerRadius(16)
                    .shadow(color: Color.theme(.gray_AFAEAE).opacity(0.05), radius: 50, x: 0, y: 10)
//                    .isSearching($context.isSearchFieldFocused)
//                    .searchable(text: $context.searchQuery, placement: .navigationBarDrawer(displayMode: .always))
//                    .compoundSearchField()
//                    .disableAutocorrection(true)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 0)
            .introspect(.scrollView, on: .supportedVersions) { scrollView in
                guard scrollView != scrollViewAdapter.scrollView else { return }
                scrollViewAdapter.scrollView = scrollView
            }
            .onReceive(scrollViewAdapter.didScroll) { _ in
                updateVisibleRange()
            }
            .onReceive(scrollViewAdapter.isScrolling) { _ in
                updateVisibleRange()
            }
            .onChange(of: context.searchQuery) {
                updateVisibleRange()
            }
            .onChange(of: context.viewState.visibleRooms) {
                updateVisibleRange()
                
                // We have been seeing a lot of issues around the room list not updating properly after
                // rooms shifting around:
                // * Tapping on the room list doesn't always take you to the right room  - https://github.com/element-hq/element-x-ios/issues/2386
                // * Big blank gaps in the room list - https://github.com/element-hq/element-x-ios/issues/3026
                //
                // We initially thought it's caused by the filters header or the geometry reader but
                // the problem is still reproducible without those.
                //
                // As a last attempt we will manually force it to update by shifting the
                // inner scroll view by a point every time the room list is updated
                DispatchQueue.main.async {
                    guard !scrollViewAdapter.isScrolling.value, let scrollView = scrollViewAdapter.scrollView else {
                        return
                    }
                    
                    let oldOffset = scrollView.contentOffset
                    var newOffset = scrollView.contentOffset
                    newOffset.y += 1
                    
                    scrollView.setContentOffset(newOffset, animated: false)
                    scrollView.setContentOffset(oldOffset, animated: false)
                }
            }
            .background {
                Button("") {
                    context.send(viewAction: .globalSearch)
                }
                .keyboardShortcut(KeyEquivalent("k"), modifiers: [.command])
            }
            .overlay {
                if context.viewState.shouldShowEmptyFilterState {
                    RoomListFiltersEmptyStateView(state: context.filtersState)
                        .background(.compound.bgCanvasDefault)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollDisabled(context.viewState.roomListMode == .skeletons)
            .scrollBounceBehavior(context.viewState.roomListMode == .empty ? .basedOnSize : .automatic)
            .animation(.elementDefault, value: context.viewState.roomListMode)
            .animation(.none, value: context.viewState.visibleRooms)
        }
    }
    
    @ViewBuilder
    private var topSection: some View {
        // An empty VStack causes glitches within the room list
        if context.viewState.shouldShowFilters || context.viewState.securityBannerMode.isShown {
            VStack(alignment: .leading, spacing: 20) {
                if context.viewState.shouldShowFilters {
                    RoomListFiltersView(state: $context.filtersState)
                }
                
                HStack(alignment: .center, spacing: 16) {
                    HStack(spacing: 12) {
                        Image("ic_search")
                        
                        TextField("", text: $context.searchQuery,
                                  prompt: Text("Search...")
                            .foregroundColor(Color.theme(.gray_A3A3A3))
                            .font(.Roboto(.regular, size: 14))
                        )
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(.keyboard)
                        .foregroundStyle(Color.theme(.black))
                        .font(.Roboto(.regular, size: 14))
                        .autocorrectionDisabled()
                        .truncationMode(.head)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.search)
                        .isSearching($context.isSearchFieldFocused)
                        .focused($isFocused)
                        .onChange(of: isFocused) { oldValue, newValue in
                            context.isSearchFieldFocused = newValue
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                    .background(Color.theme(.gray_F6F6F6))
                    .cornerRadius(16)
                    .shadow(color: Color.theme(.gray_AFAEAE).opacity(0.05), radius: 50, x: 0, y: 10)

                    if isFocused {
                        Button {
                            withAnimation {
                                isFocused = false
                            }
                        } label: {
                            Text("Cancel")
                                .foregroundColor(Color.theme(.blue_005CA7))
                                .font(.Roboto(.regular, size: 13))
                        }

                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 15)
                
                Button {
                    
                } label: {
                    HStack(spacing: 8) {
                        Image("ic_archive")
                        Text("Archive")
                            .foregroundColor(Color.theme(.gray_525252))
                            .font(.Roboto(.medium, size: 14))
                    }
                    .padding(.horizontal, 15)
                }

            
//                if case let .show(state) = context.viewState.securityBannerMode {
//                    HomeScreenRecoveryKeyConfirmationBanner(state: state, context: context)
//                }
            }
            .background(Color.clear)
            .padding(.bottom, 20)
//            .background(Color.compound.bgCanvasDefault)
        }
    }
    
    /// Often times the scroll view's content size isn't correct yet when this method is called e.g. when cancelling a search
    /// Dispatch it with a delay to allow the UI to update and the computations to be correct
    /// Once we move to iOS 17 we should remove all of this and use scroll anchors instead
    private func updateVisibleRange() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { delayedUpdateVisibleRange() }
    }
    
    private func delayedUpdateVisibleRange() {
        guard let scrollView = scrollViewAdapter.scrollView,
              scrollViewAdapter.isScrolling.value == false, // Ignore while scrolling
              context.searchQuery.isEmpty == true, // Ignore while filtering
              context.viewState.visibleRooms.count > 0 else {
            return
        }
        
        guard scrollView.contentSize.height > scrollView.bounds.height else {
            return
        }
        
        let adjustedContentSize = max(scrollView.contentSize.height - scrollView.contentInset.top - scrollView.contentInset.bottom, scrollView.bounds.height)
        let cellHeight = adjustedContentSize / Double(context.viewState.visibleRooms.count)
        
        let firstIndex = Int(max(0.0, scrollView.contentOffset.y + scrollView.contentInset.top) / cellHeight)
        let lastIndex = Int(max(0.0, scrollView.contentOffset.y + scrollView.bounds.height) / cellHeight)
        
        // This will be deduped and throttled on the view model layer
        context.send(viewAction: .updateVisibleItemRange(firstIndex..<lastIndex))
    }
}
