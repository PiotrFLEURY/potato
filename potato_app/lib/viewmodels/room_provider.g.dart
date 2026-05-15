// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(room)
final roomProvider = RoomFamily._();

final class RoomProvider
    extends $FunctionalProvider<AsyncValue<Room>, Room, FutureOr<Room>>
    with $FutureModifier<Room>, $FutureProvider<Room> {
  RoomProvider._({
    required RoomFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'roomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$roomHash();

  @override
  String toString() {
    return r'roomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Room> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Room> create(Ref ref) {
    final argument = this.argument as String;
    return room(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$roomHash() => r'29ffec3a006a99ffb744a8090742d4af02d1417e';

final class RoomFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Room>, String> {
  RoomFamily._()
    : super(
        retry: null,
        name: r'roomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RoomProvider call(String roomId) =>
      RoomProvider._(argument: roomId, from: this);

  @override
  String toString() => r'roomProvider';
}
