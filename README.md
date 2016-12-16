= HideAncestry
This gem allows hide and restore nodes from ancestry gem.
= Examples
Before hiding
```ruby
User.first.subtree
  #<ActiveRecord::Relation 
    [id: 1, name: 'Grandpa', hided_status: false],
      [id: 2, name: 'Parent', hided_status: false],
        [id: 3, name: 'Child', hided_status: false]>
```

Hiding second user
```ruby
User.second.hide!
```

Ancestry subtree became changed
```ruby
User.first.subtree
#<ActiveRecord::Relation
  [id: 1, name: 'Grandpa', hided_status: false],
    [id: 3, name: 'Child', hided_status: false]>

User.hided # hided user became separated now
#<ActiveRecord::Relation
  [id: 2, name: 'Parent', hided_status: true ]>
```

Also we can restore hided user
```ruby
User.find(2).restore # restore hided user to previous subtree

User.first.subtree
  #<ActiveRecord::Relation 
    [id: 1, name: 'Grandpa', hided_status: false],
      [id: 2, name: 'Parent', hided_status: false],
        [id: 3, name: 'Child', hided_status: false]>

User.hided
#<ActiveRecord::Relation []>
```

