# HideAncestry
This gem allows hide and restore nodes of [ancestry gem](https://github.com/stefankroes/ancestry)

### Usage
Before hiding
```ruby
User.first.subtree
  <ActiveRecord::Relation 
    [id: 1, name: 'Grandpa', hided_status: false, ancestry: nil],
      [id: 2, name: 'Parent', hided_status: false, ancestry: '1'],
        [id: 3, name: 'Child', hided_status: false, ancestry: '1/2']>
```

Hide second user
```ruby
User.second.hide
```

Ancestry subtree became changed
```ruby
User.first.subtree
#<ActiveRecord::Relation [
  <id: 1, name: 'Grandpa', hided_status: false, ancestry: nil>,
    <id: 3, name: 'Child', hided_status: false, ancestry: '1'> ]>

User.hided
#<ActiveRecord::Relation [
  <id: 2, name: 'Parent', hided_status: true, ancestry: nil>]>
```

Restoring hided user
```ruby
User.find(2).restore # restore hided user to previous subtree

User.first.subtree
#<ActiveRecord::Relation [
  <id: 1, name: 'Grandpa', hided_status: false, ancestry: nil>,
    <id: 2, name: 'Parent', hided_status: false, ancestry: '1'>,
      <id: 3, name: 'Child', hided_status: false, ancestry: '1/2'> ]>

User.hided
#<ActiveRecord::Relation []>
```
### Installation
Add to your Gemfile
``` ruby
gem 'ancestry'
gem 'hide_ancestry'
```
And install
```
bundle
```

To install hide_ancestry migration:
```ruby
rails generate hide_acestry:migration[users] # or any column with ancestry
rake db:migrate
```
It will add to the specified table:
+ old_parent_id:integer
+ old_child_ids:array  (using rails serialize)
+ hide_ancestry:string

Add to your model
```ruby
class User < ActiveRecord::Base

  has_ancestry
  has_hide_ancestry column: :hided_status # or any boolean column; you should to create it if it not exists
end
```

###Instance methods
```ruby
hide                      # hide node:
                          #   node#ancestry became nil;
                          #   node#hided_status became true
restore                   # restore node:
                          #   restore node#ancestry
                          #   node#hided_status became false
                          #   update node old descendants

hided?                    # check if node is hided
hided_parent_changed?     # check if node changed it parent
hided_children_present?   # check if node has hided children

children_of_hided         # return relation which includes children of hided node
hided_parent              # return hided parent of node if present
subtree_with_hided        # return subtree with hided nodes
hided_descendants_ids     # return ids of hided users in subtree 
hided_path_ids            # old ancestors ids of hided node

```

###Scopes
```ruby
hided            # return nodes with hided_status
unhided          # return nodes without hided_status
hided_nodes(ids) # return hided nodes with ids
hided_childs(id) # return hided nodes which was children of node#id

```

###Some notes
+ You can change ancestry subtree after hiding as you want. Hided user will be restored to previous parent and updated it old descendants
+ Hided nodes became separated without actual ancestry - no any parents or descendants