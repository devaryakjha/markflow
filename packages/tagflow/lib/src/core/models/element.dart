import 'dart:collection';

import 'package:flutter/rendering.dart';

/// Represents an HTML element in the tagflow tree.
class TagflowElement {
  /// Creates a new [TagflowElement] instance.
  TagflowElement({
    required this.tag,
    this.textContent,
    this.children = const [],
    LinkedHashMap<Object, String>? attributes,
    this.parent,
  }) : _attributes = attributes ?? LinkedHashMap.identity();

  /// Factory constructor for text nodes
  factory TagflowElement.text(String content) {
    return TagflowElement(
      tag: '#text',
      textContent: content,
    );
  }

  /// Factory constructor for empty elements
  factory TagflowElement.empty() => TagflowElement(tag: '#empty');

  /// The HTML tag name (e.g., 'div', 'p', 'h1')
  final String tag;

  /// Parent element
  TagflowElement? parent;

  /// Element's text content
  final String? textContent;

  // Element's attributes
  final LinkedHashMap<Object, String> _attributes;

  /// Child elements
  final List<TagflowElement> children;

  @override
  String toString() {
    return 'TagflowElement{tag: $tag, textContent: $textContent,'
        ' children: $children'
        ' attributes: $_attributes}';
  }
}

/// Put all the getters and setters in this extension
extension TagflowElementExtensions on TagflowElement {
  /// Returns the value of the attribute with the given name.
  String? operator [](String name) => _attributes[name];

  /// Returns the value of the attribute with the given name.
  String? get(String name) => _attributes[name];

  /// Returns true if the element has the given attribute.
  bool hasAttribute(String name) => _attributes.containsKey(name);

  /// Return class attribute value
  String get className => _attributes['class'] ?? '';

  /// Returns the list of class names
  List<String> get classList => className.split(' ');

  /// Sets the class attribute value
  set className(String value) => _attributes['class'] = value;

  /// Sets the class attribute value
  set classList(List<String> value) {
    _attributes['class'] = value.join(' ');
  }

  /// Whether this element represents a text node
  bool get isTextNode => tag == '#text' && textContent != null;

  /// Whether this element is an empty element
  bool get isEmpty => tag == '#empty';

  /// The tag name of the parent element
  String get parentTag => parent?.tag ?? '';

  /// Adds a child element to this element.
  void addAllChildren(Iterable<TagflowElement> children) {
    this.children.addAll(children);
  }

  /// Adds a child element to this element.
  void addChild(TagflowElement child) {
    children.add(child);
  }

  /// Adds a parent element to this element.
  /// and recursively adds all children of this element to the new parent.
  void reparent([TagflowElement? newParent]) {
    parent = newParent;
    for (final child in children) {
      child.reparent(this);
    }
  }
}

/// All extensions for [TagflowElement] that are specific to anchor elements
extension TagflowAnchorElement on TagflowElement {
  /// Whether this element represents an anchor element
  bool get isAnchor => tag == 'a';

  /// The anchor's href attribute
  String? get href => _attributes['href'];

  /// The anchor's target attribute
  String? get parentHref => parent?.href;
}

/// All extensions for [TagflowElement] that are specific to img elements
extension TagflowImgElement on TagflowElement {
  /// The image's src attribute
  String get src => _attributes['src']!;

  /// The image's alt attribute
  String get alt => _attributes['alt']!;

  /// Image's fit attribute
  // convert css fit values to flutter fit values
  BoxFit? get fit => switch (styles?['object-fit']) {
        'contain' => BoxFit.contain,
        'cover' => BoxFit.cover,
        'fill' => BoxFit.fill,
        'none' => BoxFit.none,
        'scale-down' => BoxFit.scaleDown,
        'scale-down-x' => BoxFit.scaleDown,
        'scale-down-y' => BoxFit.scaleDown,
        _ => null,
      };
}

/// All extensions for [TagflowElement] that are specific to style attributes
extension TagflowElementStyleExtensions on TagflowElement {
  /// The style of the element
  String? get style => _attributes['style'];

  /// The styles of the element
  LinkedHashMap<Object, String>? get styles {
    if (style == null) {
      return null;
    }
    return LinkedHashMap.fromEntries(
      style!.split(';').map((e) {
        final parts = e.split(':');
        return MapEntry(parts[0].trim(), parts[1].trim());
      }),
    );
  }

  /// Whether the element has the given style
  bool hasStyle(String name) => styles?.containsKey(name) ?? false;
}

/// All extensions for [TagflowElement] that are specific to sizing attributes
extension TagflowElementSizeExtensions on TagflowElement {
  /// The width of the element
  double? get width => hasAttribute('width')
      ? double.tryParse(_attributes['width']!)
      : hasStyle('width')
          ? double.tryParse(styles!['width']!)
          : null;

  /// The height of the element
  double? get height => hasAttribute('height')
      ? double.tryParse(_attributes['height']!)
      : hasStyle('height')
          ? double.tryParse(styles!['height']!)
          : null;
}