/*
 *  This file is part of wrld999 (https://github.com/shad0wrider/wrld999).
 * 
 * wrld999 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wrld999 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with wrld999.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2022, Ankit Sangwan
 */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:wrld999/CustomWidgets/bouncy_playlist_header_scroll_view.dart';
import 'package:wrld999/CustomWidgets/copy_clipboard.dart';
import 'package:wrld999/CustomWidgets/gradient_containers.dart';
import 'package:wrld999/CustomWidgets/miniplayer.dart';
import 'package:wrld999/CustomWidgets/playlist_popupmenu.dart';
import 'package:wrld999/CustomWidgets/song_tile_trailing_menu.dart';
import 'package:wrld999/Services/player_service.dart';
import 'package:wrld999/Services/youtube_services.dart';
import 'package:wrld999/Services/yt_music.dart';
import 'package:wrld999/localization/app_localizations.dart';

class YouTubePlaylist extends StatefulWidget {
  final String playlistId;
  final String type;
  // final String playlistName;
  // final String? playlistSubtitle;
  // final String? playlistSecondarySubtitle;
  // final String playlistImage;
  const YouTubePlaylist({
    super.key,
    required this.playlistId,
    this.type = 'playlist',
    // required this.playlistName,
    // required this.playlistSubtitle,
    // required this.playlistSecondarySubtitle,
    // required this.playlistImage,
  });

  @override
  _YouTubePlaylistState createState() => _YouTubePlaylistState();
}

class _YouTubePlaylistState extends State<YouTubePlaylist> {
  bool status = false;
  List<Map> searchedList = [];
  bool fetched = false;
  bool done = true;
  final ScrollController _scrollController = ScrollController();
  String playlistName = '';
  String playlistSubtitle = '';
  String? playlistSecondarySubtitle;
  String playlistImage = '';

  @override
  void initState() {
    if (!status) {
      status = true;
      if (widget.type == 'playlist') {
        YtMusicService().getPlaylistDetails(widget.playlistId).then((value) {
          final songs = value['songs'] as List<Map>? ?? [];
          if (songs.isNotEmpty) {
            setState(() {
              try {
                searchedList = songs;
                playlistName = value['name'] as String? ?? '';
                playlistSubtitle = value['subtitle'] as String? ?? '';
                playlistSecondarySubtitle = value['description'] as String?;
                playlistImage =
                    (value['images'] as List?)?.last as String? ?? '';
                fetched = true;
              } catch (e) {
                Logger.root.severe('Error in fetching playlist details', e);
                fetched = true;
              }
            });
          } else {
            // Fallback for RDCLAK and other YouTube playlist IDs
            YouTubeServices()
                .getPlaylistSongs(widget.playlistId)
                .then((videos) {
              setState(() {
                searchedList = videos
                    .map(
                      (v) => <String, dynamic>{
                        'id': v.id.value,
                        'title': v.title,
                        'artist':
                            v.author.replaceAll('- Topic', '').trim(),
                        'image': v.thumbnails.highResUrl,
                        'duration':
                            v.duration?.inSeconds.toString() ?? '0',
                        'language': 'YouTube',
                        'genre': 'YouTube',
                      },
                    )
                    .toList();
                fetched = true;
              });
            }).catchError((e) {
              Logger.root.severe('Error in fallback playlist fetch', e);
              setState(() {
                fetched = true;
              });
            });
          }
        });
      } else if (widget.type == 'album') {
        YtMusicService().getAlbumDetails(widget.playlistId).then((value) {
          setState(() {
            try {
              searchedList = value['songs'] as List<Map>? ?? [];
              playlistName = value['name'] as String? ?? '';
              playlistSubtitle = value['subtitle'] as String? ?? '';
              playlistSecondarySubtitle = value['description'] as String?;
              playlistImage = (value['images'] as List?)?.last as String? ?? '';
              fetched = true;
            } catch (e) {
              Logger.root.severe('Error in fetching playlist details', e);
              fetched = true;
            }
          });
        });
      } else if (widget.type == 'artist') {
        YtMusicService().getArtistDetails(widget.playlistId).then((value) {
          setState(() {
            try {
              searchedList = value['songs'] as List<Map>? ?? [];
              playlistName = value['name'] as String? ?? '';
              playlistSubtitle = value['subtitle'] as String? ?? '';
              playlistSecondarySubtitle = value['description'] as String?;
              playlistImage = (value['images'] as List?)?.last as String? ?? '';
              fetched = true;
            } catch (e) {
              Logger.root.severe('Error in fetching playlist details', e);
              fetched = true;
            }
          });
        });
      }
      // YouTubeServices().getPlaylistSongs(widget.playlistId).then((value) {
      //   if (value.isNotEmpty) {
      //     setState(() {
      //       searchedList = value;
      //       fetched = true;
      //     });
      //   } else {
      //     status = false;
      //   }
      // });
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext cntxt) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  if (!fetched)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    BouncyPlaylistHeaderScrollView(
                      scrollController: _scrollController,
                      title: playlistName,
                      subtitle: playlistSubtitle,
                      secondarySubtitle: playlistSecondarySubtitle,
                      imageUrl: playlistImage,
                      actions: [
                        PlaylistPopupMenu(
                          data: searchedList,
                          title: playlistName,
                        ),
                      ],
                      onPlayTap: () async {
                        if (searchedList.isEmpty) return;
                        setState(() {
                          done = false;
                        });

                        final Map? response =
                            await YouTubeServices().formatVideoFromId(
                          id: searchedList.first['id'].toString(),
                          data: searchedList.first,
                        );
                        if (response == null) {
                          setState(() {
                            done = true;
                          });
                          return;
                        }
                        final List<Map> playList = List.from(searchedList);
                        playList[0] = response;
                        setState(() {
                          done = true;
                        });
                        PlayerInvoke.init(
                          songsList: playList,
                          index: 0,
                          isOffline: false,
                          recommend: false,
                        );
                        Navigator.pushNamed(context, '/player');
                      },
                      onShuffleTap: () async {
                        setState(() {
                          done = false;
                        });
                        final List<Map> playList = List.from(searchedList);
                        playList.shuffle();
                        final Map? response =
                            await YouTubeServices().formatVideoFromId(
                          id: playList.first['id'].toString(),
                          data: playList.first,
                        );
                        playList[0] = response!;
                        setState(() {
                          done = true;
                        });
                        PlayerInvoke.init(
                          songsList: playList,
                          index: 0,
                          isOffline: false,
                          recommend: false,
                        );
                        Navigator.pushNamed(context, '/player');
                      },
                      sliverList: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            if (searchedList.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  top: 5.0,
                                  bottom: 5.0,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.songs,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ...searchedList.map(
                              (Map entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 5.0,
                                  ),
                                  child: ListTile(
                                    leading: widget.type == 'album'
                                        ? null
                                        : Card(
                                            margin: EdgeInsets.zero,
                                            elevation: 8,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                5.0,
                                              ),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: SizedBox.square(
                                              dimension: 50,
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                errorWidget: (context, _, __) =>
                                                    const Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                    'assets/cover.jpg',
                                                  ),
                                                ),
                                                imageUrl:
                                                    entry['image'].toString(),
                                                placeholder: (context, url) =>
                                                    const Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                    'assets/cover.jpg',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    title: Text(
                                      entry['title'].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onLongPress: () {
                                      copyToClipboard(
                                        context: context,
                                        text: entry['title'].toString(),
                                      );
                                    },
                                    subtitle: (entry['subtitle'] == null ||
                                            entry['subtitle'] == '')
                                        ? null
                                        : Text(
                                            entry['subtitle'].toString(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                    onTap: () async {
                                      setState(() {
                                        done = false;
                                      });
                                      final Map? response =
                                          await YouTubeServices()
                                              .formatVideoFromId(
                                        id: entry['id'].toString(),
                                        data: entry,
                                      );
                                      setState(() {
                                        done = true;
                                      });
                                      PlayerInvoke.init(
                                        songsList: [response],
                                        index: 0,
                                        isOffline: false,
                                      );
                                      Navigator.pushNamed(context, '/player');
                                      // for (var i = 0;
                                      //     i < searchedList.length;
                                      //     i++) {
                                      //   YouTubeServices()
                                      //       .formatVideo(
                                      //     video: searchedList[i],
                                      //     quality: Hive.box('settings')
                                      //         .get(
                                      //           'ytQuality',
                                      //           defaultValue: 'Low',
                                      //         )
                                      //         .toString(),
                                      //   )
                                      //       .then((songMap) {
                                      //     final MediaItem mediaItem =
                                      //         MediaItemConverter.mapToMediaItem(
                                      //       songMap!,
                                      //     );
                                      //     addToNowPlaying(
                                      //       context: context,
                                      //       mediaItem: mediaItem,
                                      //       showNotification: false,
                                      //     );
                                      //   });
                                      // }
                                    },
                                    trailing:
                                        YtSongTileTrailingMenu(data: entry),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!done)
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width / 2,
                        width: MediaQuery.of(context).size.width / 2,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: GradientContainer(
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.useHome,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.secondary,
                                    ),
                                    strokeWidth: 5,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .fetchingStream,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}
