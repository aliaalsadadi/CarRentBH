//
//  Generated code. Do not modify.
//  source: cars.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use carDescriptor instead')
const Car$json = {
  '1': 'Car',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'photoUrl', '3': 2, '4': 1, '5': 9, '10': 'photoUrl'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `Car`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List carDescriptor = $convert.base64Decode(
    'CgNDYXISDgoCaWQYASABKAlSAmlkEhoKCHBob3RvVXJsGAIgASgJUghwaG90b1VybBIgCgtkZX'
    'NjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24=');

@$core.Deprecated('Use queryDescriptor instead')
const Query$json = {
  '1': 'Query',
  '2': [
    {'1': 'Query', '3': 1, '4': 1, '5': 9, '10': 'Query'},
  ],
};

/// Descriptor for `Query`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryDescriptor = $convert.base64Decode(
    'CgVRdWVyeRIUCgVRdWVyeRgBIAEoCVIFUXVlcnk=');

@$core.Deprecated('Use addResponseDescriptor instead')
const AddResponse$json = {
  '1': 'AddResponse',
  '2': [
    {'1': 'added', '3': 1, '4': 1, '5': 8, '10': 'added'},
  ],
};

/// Descriptor for `AddResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addResponseDescriptor = $convert.base64Decode(
    'CgtBZGRSZXNwb25zZRIUCgVhZGRlZBgBIAEoCFIFYWRkZWQ=');

@$core.Deprecated('Use searchResponseDescriptor instead')
const SearchResponse$json = {
  '1': 'SearchResponse',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 9, '10': 'ids'},
  ],
};

/// Descriptor for `SearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchResponseDescriptor = $convert.base64Decode(
    'Cg5TZWFyY2hSZXNwb25zZRIQCgNpZHMYASADKAlSA2lkcw==');

