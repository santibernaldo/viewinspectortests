//
//  SpotListComment.swift
//  RemoteSpotiOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 15/1/25.
//

import SwiftUI

public struct SpotCommentCell: View {
    let comment: RSComment
    @Environment(\.imageCache) private var cache: ImageCache
    @Binding var isLoading: Bool
    
    init(comment: RSComment, isLoading: Binding<Bool>) {
        self.comment = comment
        _isLoading = isLoading
    }
    
    public var body: some View {
        Group {
            HStack(alignment: .top, spacing: 12) {
                if let urlProfileImage = URL(string: comment.profileImageURL) {
                    AsyncImageImageLoader(
                        url: urlProfileImage,
                        isLoading: isLoading,
                        placeholder: {
                            Image("placeHolderWhiteImage")
                                .frame(height: 40)
                                .frame(width: 40)
                            
                        },
                        cache: cache,
                        content: {
                            Image(uiImage: $0)
                                .resizable()
                                .scaledToFill()
                        }
                    )
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.leading, 4)
                    .padding(.top, 8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(comment.username)
                            .bold()
                        Spacer()
                        Text(comment.timeFormatted())
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                    Text(comment.text)
                        .font(.body)
                }
                .padding(.vertical, 4)
            }
            
        }
    }
    
}
