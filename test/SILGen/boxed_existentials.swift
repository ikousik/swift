// RUN: %target-swift-frontend -emit-silgen %s | FileCheck %s

func test_type_lowering(x: _ErrorType) { }
// CHECK-LABEL: sil hidden @_TF18boxed_existentials18test_type_loweringFPSs10_ErrorType_T_ : $@thin (@owned _ErrorType) -> () {
// CHECK:         strong_release %0 : $_ErrorType

class Document {}

enum ClericalError: _ErrorType {
  case MisplacedDocument(Document)

  var domain: String { return "" }
  var code: Int { return 0 }
}

func test_concrete_erasure(x: ClericalError) -> _ErrorType {
  return x
}
// CHECK-LABEL: sil hidden @_TF18boxed_existentials21test_concrete_erasureFOS_13ClericalErrorPSs10_ErrorType_
// CHECK:         [[EXISTENTIAL:%.*]] = alloc_existential_box $_ErrorType, $ClericalError
// CHECK:         store %0 to [[EXISTENTIAL]]#1 : $*ClericalError
// CHECK:         return [[EXISTENTIAL]]#0 : $_ErrorType

protocol HairType {}

func test_composition_erasure(x: protocol<HairType, _ErrorType>) -> _ErrorType {
  return x
}
// CHECK-LABEL: sil hidden @_TF18boxed_existentials24test_composition_erasureFPSs10_ErrorTypeS_8HairType_PS0__
// CHECK:         [[VALUE_ADDR:%.*]] = open_existential_addr [[OLD_EXISTENTIAL:%.*]] : $*protocol<_ErrorType, HairType> to $*[[VALUE_TYPE:@opened\(.*\) protocol<_ErrorType, HairType>]]
// CHECK:         [[NEW_EXISTENTIAL:%.*]] = alloc_existential_box $_ErrorType, $[[VALUE_TYPE]]
// CHECK:         copy_addr [take] [[VALUE_ADDR]] to [initialization] [[NEW_EXISTENTIAL]]#1
// CHECK:         deinit_existential_addr [[OLD_EXISTENTIAL]]
// CHECK:         return [[NEW_EXISTENTIAL]]#0

protocol HairClassType: class {}

func test_class_composition_erasure(x: protocol<HairClassType, _ErrorType>) -> _ErrorType {
  return x
}
// CHECK-LABEL: sil hidden @_TF18boxed_existentials30test_class_composition_erasureFPSs10_ErrorTypeS_13HairClassType_PS0__
// CHECK:         [[VALUE:%.*]] = open_existential_ref [[OLD_EXISTENTIAL:%.*]] : $protocol<_ErrorType, HairClassType> to $[[VALUE_TYPE:@opened\(.*\) protocol<_ErrorType, HairClassType>]]
// CHECK:         [[NEW_EXISTENTIAL:%.*]] = alloc_existential_box $_ErrorType, $[[VALUE_TYPE]]
// CHECK:         store [[VALUE]] to [[NEW_EXISTENTIAL]]#1
// CHECK:         return [[NEW_EXISTENTIAL]]#0

func test_property(x: _ErrorType) -> String {
  return x.domain
}
// CHECK-LABEL: sil hidden @_TF18boxed_existentials13test_propertyFPSs10_ErrorType_SS
// CHECK:         [[VALUE:%.*]] = open_existential_box %0 : $_ErrorType to $*[[VALUE_TYPE:@opened\(.*\) _ErrorType]]
// CHECK:         [[METHOD:%.*]] = witness_method $[[VALUE_TYPE]], #_ErrorType.domain!getter.1
// -- self parameter of witness is @in_guaranteed; no need to copy since
//    value in box is immutable and box is guaranteed
// CHECK:         [[RESULT:%.*]] = apply [[METHOD]]<[[VALUE_TYPE]]>([[VALUE]])
// CHECK:         strong_release %0
// CHECK:         return [[RESULT]]