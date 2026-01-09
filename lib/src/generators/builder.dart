import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'safe_json_mapper_generator.dart';

Builder safeJsonMapperBuilder(BuilderOptions options) =>
    SharedPartBuilder([SafeJsonModelGenerator()], 'safe_json_mapper');
