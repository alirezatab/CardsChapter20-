/// Copyright (c) 2023 Kodeco
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct CardsListView: View {
  @EnvironmentObject var store: CardStore
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Environment(\.verticalSizeClass) var verticalSizeClass
  @State private var selectedCard: Card?

  var thumbnailSize: CGSize {
    var scale: CGFloat = 1
    if verticalSizeClass == .regular, horizontalSizeClass == .regular {
      scale = 1.5
    }
    return Settings.thumbnailSize * scale
  }
  
  // This returns an array of GridItem — in this case, with one element — you can use this to tell the LazyVGrid the size and position of each row. This GridItem is adaptive, which means the grid will fit as many items as possible with the minimum size provided.
  var columns: [GridItem] {
    [
      GridItem(.adaptive(
        minimum: thumbnailSize.width))
    ]
  }
  
  var body: some View {
    VStack {
      // You place these two views in a Group so that fullScreenCover(item:onDismiss:content:) modifies both views.
      Group {
        if store.cards.isEmpty {
          inititalView
        } else {
          list
        }
      }
      .fullScreenCover(item: $selectedCard) { card in
        if let index = store.index(for: card) {
          SingleCardView(card: $store.cards[index])
            .onChange(of: scenePhase) { newScenePhase in
              if newScenePhase == .inactive {
                store.cards[index].save()
              }
            }
        } else {
          fatalError("Unable to locate selected card")
        }
      }
      createButton
    }
    .background(
      Color("background")
        .ignoresSafeArea())
  }

  var list: some View {
    ScrollView(showsIndicators: false) {
      LazyVGrid(columns: columns, spacing: 30) {
        ForEach(store.cards) { card in
          CardThumbnail(card: card)
            .contextMenu {
              Button(role: .destructive) {
                store.remove(card)
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
            .frame(
              width: thumbnailSize.width,
              height: thumbnailSize.height)
            .onTapGesture {
              selectedCard = card
            }
        }
      }
    }
    .padding(.top, 20)
  }
  
  var inititalView: some View {
    VStack {
      Spacer()
      let card = Card(
        backgroundColor: Color(uiColor: .systemBackground))
      ZStack {
        CardThumbnail(card: card)
        Image(systemName: "plus.circle.fill")
          .font(.largeTitle)
      }
      .frame(
        width: thumbnailSize.width * 1.2,
        height: thumbnailSize.height * 1.2)
      .onTapGesture {
        selectedCard = store.addCard()
      }
      
      Spacer()
    }
  }
  
  var createButton: some View {
    // 1 - Create a simple button using a Label format so that you can specify a system image. When tapped, you create a new card and assign it to selectedCard. When selectedCard changes, SingleCardView will show.
    Button {
      selectedCard = store.addCard()
    } label: {
      Label("Create New", systemImage: "plus")
      // 2 - The button stretches all the way across the screen, less the padding.
        .frame(maxWidth: .infinity)
    }
    .font(.system(size: 16, weight: .bold))
    .padding([.top, .bottom], 10)
    // 3 - The background color is in the asset catalog. You’ll customize the button text color shortly.
    .background(Color("barColor"))
    .accentColor(.white)
  }
}

struct CardsListView_Previews: PreviewProvider {
  static var previews: some View {
    CardsListView()
      .environmentObject(CardStore(defaultData: true))
  }
}
