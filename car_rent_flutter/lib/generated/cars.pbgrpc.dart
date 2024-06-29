//
//  Generated code. Do not modify.
//  source: cars.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'cars.pb.dart' as $0;

export 'cars.pb.dart';

@$pb.GrpcServiceName('ChromaService')
class ChromaServiceClient extends $grpc.Client {
  static final _$addCar = $grpc.ClientMethod<$0.Car, $0.AddResponse>(
      '/ChromaService/AddCar',
      ($0.Car value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddResponse.fromBuffer(value));
  static final _$searchCars = $grpc.ClientMethod<$0.Query, $0.SearchResponse>(
      '/ChromaService/SearchCars',
      ($0.Query value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SearchResponse.fromBuffer(value));

  ChromaServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.AddResponse> addCar($0.Car request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$addCar, request, options: options);
  }

  $grpc.ResponseFuture<$0.SearchResponse> searchCars($0.Query request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$searchCars, request, options: options);
  }
}

@$pb.GrpcServiceName('ChromaService')
abstract class ChromaServiceBase extends $grpc.Service {
  $core.String get $name => 'ChromaService';

  ChromaServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Car, $0.AddResponse>(
        'AddCar',
        addCar_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Car.fromBuffer(value),
        ($0.AddResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Query, $0.SearchResponse>(
        'SearchCars',
        searchCars_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Query.fromBuffer(value),
        ($0.SearchResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.AddResponse> addCar_Pre($grpc.ServiceCall call, $async.Future<$0.Car> request) async {
    return addCar(call, await request);
  }

  $async.Future<$0.SearchResponse> searchCars_Pre($grpc.ServiceCall call, $async.Future<$0.Query> request) async {
    return searchCars(call, await request);
  }

  $async.Future<$0.AddResponse> addCar($grpc.ServiceCall call, $0.Car request);
  $async.Future<$0.SearchResponse> searchCars($grpc.ServiceCall call, $0.Query request);
}
